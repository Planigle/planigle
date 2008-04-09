class Task < ActiveRecord::Base
  belongs_to :individual
  belongs_to :story
  
  validates_presence_of     :name, :story_id
  validates_length_of       :name,                   :within => 1..40
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  attr_accessible :name, :description, :effort, :status_code, :iteration_id, :individual_id, :story_id

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # A task should inherit its owner from its story.
  def story=(story)
    self.individual_id = story.individual_id
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

  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, 'Invalid status')
    end
    
    if individual_id && !Individual.find_by_id(individual_id)
      errors.add(:individual_id, 'Owner not valid')
    end
    
    if !story_id || !Story.find_by_id(story_id)
      errors.add(:story_id, 'Story not valid')
    end
  end
end