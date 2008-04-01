class Story < ActiveRecord::Base
  belongs_to :iteration
  
  validates_presence_of     :name
  validates_length_of       :name,                   :within => 1..40
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :acceptance_criteria,    :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  attr_accessible :name, :description, :acceptance_criteria, :effort, :status, :iteration_id

  # Assign a priority on creation
  before_create :initialize_priority

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # Switch the priority of the stories with the sent ids in the order specified.  Return the stories affected.
  def self.sort( ids )
    stories = ids.collect { |id| self.find(id) }
    priorities = stories.collect {|story| story.priority}.sort
    i = 0
    stories.each do |story|
      story.priority = priorities[i]
      i += 1
    end
    stories
  end
  
  # Answer my status.
  def status()
    StatusMapping[status_code]
  end

  # Set status.
  def status=(status)
    code = StatusMapping.index(status)
    self.status_code = code ? code : -1 # -1 will result in a status error.
  end

  # Add custom validation of the status field to give a more specific message.
  def validate()
    if status_code == -1
      errors.add(:status, 'Status must be one of: Created, In Progress, Accepted')
    end
  end

  # Override to_xml to exclude private attributes.
  def to_xml(options = {})
    if !options[:except]
      options[:except] = [:status_code, :priority]
    end
    if !options[:methods]
      options[:methods] = [:status]
    end
    super(options)
  end
  
private
  
  # Set the initial priority to the number of stories (+1 for me).
  def initialize_priority
    highest = Story.find(:first, :order=>'priority desc')
    self.priority = highest ? highest.priority + 1 : 1
  end
end
