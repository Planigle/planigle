class Company < ActiveRecord::Base
  has_many :projects, :dependent => :destroy
  has_many :individuals, :dependent => :nullify # Delete non-admins
  attr_accessible :name
  acts_as_audited

  validates_presence_of     :name
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug

  # Delete all non-admins
  def destroy
    Individual.delete_all(["company_id = ? and role != 0", id])
    super
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin
      Company.find(:all, :include => [:projects], :conditions => ["companies.id = ?", current_user.company_id])
    else
      Company.find(:all, :include => [:projects], :order => 'companies.name')
    end
  end
  
  # Override to_xml to include projects.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:projects]
    end
    super(options)
  end

  # Only admins can create projects.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else current_user.company_id == id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)    
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.company_id == id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    current_user.role <= Individual::Admin
  end
end