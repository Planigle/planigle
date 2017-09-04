class Release < ActiveRecord::Base
  include Utilities::Text
  acts_as_paranoid
  belongs_to :project
  has_many :story_attribute_values, :dependent => :destroy
  has_many :stories, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :release_totals, :dependent => :destroy
  audited
 
  validates_presence_of     :project_id, :name, :start, :finish
  validates_length_of       :name,   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validate :validate

  # Answer the records for a particular user.
  def self.get_records(project_id, historical=false)
    where = "project_id = :project_id"
    if historical
      where += " AND start <= CURDATE()"
    end
    Release.where([where, {project_id: project_id}]).order('start')
  end

  # Answer the current release for a particular user.
  def self.find_current(project_id)
    project_id ? Release.where(["project_id = :project_id and start <= CURDATE() and finish >= CURDATE()", {project_id: project_id}]).order('start,finish').first : nil
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
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

  # Override as_json to exclude private attributes.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at]
    end
    super(options)
  end  
  
protected
  
  # Ensure finish is after start.
  def validate
    errors.add(:finish, 'must be after start') if finish && start && finish < start
  end
end