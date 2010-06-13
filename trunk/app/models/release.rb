class Release < ActiveRecord::Base
  include Utilities::Text
  belongs_to :project
  has_many :story_attribute_values, :dependent => :destroy
  has_many :stories, :dependent => :nullify, :conditions => "stories.deleted_at IS NULL"
  has_many :release_totals, :dependent => :destroy
  attr_accessible :name, :start, :finish, :project_id
  acts_as_audited
  acts_as_paranoid
 
  validates_presence_of     :project_id, :name, :start, :finish
  validates_length_of       :name,   :maximum => 40, :allow_nil => true # Allow nil to workaround bug

  # Answer the records for a particular user.
  def self.get_records(current_user)
    Release.find(:all, :conditions => ["project_id = ?", current_user.project_id], :order => 'start')
  end

  # Answer the current release for a particular user.
  def self.find_current(current_user)
    current_user.project_id ? Release.find(:first, :conditions => ["project_id = ? and start <= CURDATE() and finish >= CURDATE()", current_user.project_id], :order => 'start DESC') : nil
  end

  # Summarize my current data.
  def summarize
    ReleaseTotal.summarize_for(self)
  end
  
  # Answer whether the user is authorized to create me.
  def authorized_for_create?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
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
      when Individual::ProjectAdmin then current_user.project_id == project_id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
      else false
    end
  end
  
protected
  
  # Ensure finish is after start.
  def validate
    errors.add(:finish, 'must be after start') if finish && start && finish < start
  end
end