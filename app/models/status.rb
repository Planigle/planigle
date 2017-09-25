class Status < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :project
  has_many :stories, -> {where(deleted_at: nil)}, dependent: :restrict_with_exception
  has_many :tasks, -> {where(deleted_at: nil)}, dependent: :restrict_with_exception
  audited
  
  validates_presence_of     :project_id, :name, :ordering, :status_code, :applies_to_stories, :applies_to_tasks
  validates_length_of       :name, :maximum => 20
  validates_numericality_of :ordering, :status_code
  validates :applies_to_stories, inclusion: { in: [ true, false ] }
  validates :applies_to_tasks, inclusion: { in: [ true, false ] }

  StatusMapping = [ 'Not Started', 'In Progress', 'Blocked', 'Done' ]

  @@Created = 0
  cattr_reader :Created
  
  @@InProgress = 1
  cattr_reader :InProgress
  
  @@Blocked = 2
  cattr_reader :Blocked
  
  @@Done = 3
  cattr_reader :Done

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end
  
  # Map user displayable terms to the internal status codes.
  def self.status_code_mapping
    map = {}
    i = -1
    valid_status_values.each { |val| i+=1; map[val]=i }
    map
  end

  # Override as_json to exclude change dates
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at]
    end
    super(options)
  end

  # Answer the records for a particular project.
  def self.get_records(project_id)
    Status.where(["project_id = :project_id", {project_id: project_id}]).order('ordering')
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
end