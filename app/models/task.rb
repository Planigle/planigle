class Task < ActiveRecord::Base
  belongs_to :individual
  belongs_to :story
  
  validates_presence_of     :name, :story_id
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true
  validates_numericality_of :status_code

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  attr_accessible :name, :description, :effort, :status_code, :iteration_id, :individual_id, :story_id

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # Map user displayable terms to the internal status codes.
  def self.status_code_mapping
    i = -1
    valid_status_values.collect { |val| i+=1;[val, i] }
  end

  # A task should inherit its owner from its story.
  def story=(story)
    if !self.individual_id
      self.individual_id = story.individual_id
    end
    write_attribute(:story_id, story.id)
  end
  
  # A task should inherit its owner from its story.
  def story_id=(story_id)
    self.story=(Story.find(story_id))
  end

  # Answer my status in a user friendly format.
  def status
    StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == 2
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

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
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
    
    errors.add(:effort, 'must be greater than 0') if effort && effort <= 0
  end
end