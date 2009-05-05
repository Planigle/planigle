class Criterium < ActiveRecord::Base
  belongs_to :story
  attr_accessible :description, :status_code, :story_id, :priority
  acts_as_audited :except => [:story_id]
  
  validates_presence_of     :description
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :status_code
  validates_numericality_of :priority, :allow_nil => true # Needed for priority since not set until after check

  # Assign a priority on creation
  before_create :initialize_defaults

  Created = 0
  Done = 1

  StatusMapping = [ 'Not Started', 'Done' ]

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == Done
  end

  # Answer a string which I can be referred to by.
  def name
    max_length=20
    description[0,description.length>max_length ? max_length : description.length ] + (description.length > max_length ? '...' : '')
  end

  # Set the initial priority to the number of tasks (+1 for me).
  def initialize_defaults
    if !self.priority && story
      highest = story.criteria.find(:first, :order=>'priority desc')
      self.priority = highest ? highest.priority + 1 : 1
    end
  end

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, ' is invalid')
    end
    
    if story_id && !Story.find_by_id(story_id)
      errors.add(:story_id, ' is invalid')
    end
  end
end