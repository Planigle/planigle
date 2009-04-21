class Task < ActiveRecord::Base
  belongs_to :individual
  belongs_to :story
  attr_accessible :name, :description, :effort, :status_code, :iteration_id, :individual_id, :story_id, :reason_blocked, :priority
  acts_as_audited :except => [:story_id]
  
  validates_presence_of     :name, :story_id
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :reason_blocked,         :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :status_code
  validates_numericality_of :priority, :allow_nil => true # Needed for priority since not set until after check

  # Assign a priority on creation
  before_create :initialize_defaults

  # Answer the valid values for status.
  def self.valid_status_values()
    Story::StatusMapping
  end

  # Map user displayable terms to the internal status codes.
  def self.status_code_mapping
    i = -1
    valid_status_values.collect { |val| i+=1;[val, i] }
  end

  # Answer my status in a user friendly format.
  def status
    Story::StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == Story::Done
  end

  # Only project users or higher can create tasks.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    elsif current_user.role <= Individual::ProjectUser && story && current_user.project_id == story.project_id
      true
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else story && current_user.project_id == story.project_id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then story && current_user.project_id == story.project_id
      when Individual::ProjectUser then story && current_user.project_id == story.project_id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then story && current_user.project_id == story.project_id
      when Individual::ProjectUser then story && current_user.project_id == story.project_id
      else false
    end
  end

  # Answer whether I am blocked.
  def is_blocked
    status_code == Story::Blocked
  end
  
  # Answer a string which describes my blocked state.
  def blocked_message
    name + " is blocked" + (reason_blocked && reason_blocked != "" ? " because " + reason_blocked : "") + "."
  end
  
  # Set the initial priority to the number of tasks (+1 for me).
  def initialize_defaults
    if !self.priority
      highest = story.tasks.find(:first, :order=>'priority desc')
      self.priority = highest ? highest.priority + 1 : 1
    end
  end

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= Story::StatusMapping.length
      errors.add(:status_code, ' is invalid')
    end
    
    if individual_id && !Individual.find_by_id(individual_id)
      errors.add(:individual_id, ' is invalid')
    elsif individual && story.project_id != individual.project_id
      errors.add(:individual_id, ' is not from a valid project')
    end
    
    if story_id && !Story.find_by_id(story_id)
      errors.add(:story_id, ' is invalid')
    end
  end
end