class Team < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :project
  has_many :individuals, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :stories, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :release_totals, :dependent => :destroy
  has_many :iteration_totals, :dependent => :destroy
  has_many :iteration_velocities, :dependent => :destroy
  audited :except => [:project_id]

  validates_presence_of     :name
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true

  # Override as_json to exclude private attributes.
  def serializable_hash(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at]
    end
    super(options)
  end  

  # Only admins can create projects.
  def authorized_for_create?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.company_id == project.company_id
      else false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else current_user.project_id == project_id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)    
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.company_id == project.company_id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
    when Individual::ProjectAdmin then current_user.company_id == project.company_id
      else false
    end
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end
end