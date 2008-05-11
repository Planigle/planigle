class Story < ActiveRecord::Base
  include Utilities::Text
  belongs_to :project
  belongs_to :iteration
  belongs_to :individual
  has_many :tasks, :dependent => :destroy
  
  validates_presence_of     :project_id, :name
  validates_length_of       :name,                   :within => 1..40
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :acceptance_criteria,    :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  attr_accessible :name, :description, :acceptance_criteria, :effort, :status_code, :iteration_id, :individual_id, :project_id

  # Assign a priority on creation
  before_create :initialize_priority

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # Map user displayable terms to the internal status codes.
  def self.status_code_mapping
    i = -1
    valid_status_values.collect { |val| i+=1;[val, i] }
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
  
  # Answer my status in a user friendly format.
  def status
    StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == 2
  end
  
  # My effort is either my value (if set) or the sum of my tasks.
  def effort
    eff = read_attribute(:effort)
    eff ? eff : tasks.sum(:effort)
  end
  
  # Create a new story based on this one.
  def split
    next_iteration = self.iteration ? Iteration.find(:first, :conditions => ["start>? and project_id=?", self.iteration.start, self.project_id], :order => 'start') : nil
    Story.new(
      :name => increment_name(self.name, self.name + as_(' Part Two')),
      :project_id => self.project_id,
      :iteration_id => next_iteration ? next_iteration.id : nil,
      :individual_id => self.individual_id,
      :description => self.description,
      :acceptance_criteria => self.acceptance_criteria,
      :effort => raw_effort )
  end
  
protected

  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, 'is invalid')
    end
    
    if iteration_id && !Iteration.find_by_id(iteration_id)
      errors.add(:iteration_id, 'is invalid')
    elsif iteration && project_id != iteration.project_id
      errors.add(:iteration_id, 'is not from a valid project')
    end
    
    if individual_id && !Individual.find_by_id(individual_id)
      errors.add(:individual_id, 'is invalid')
    elsif individual && project_id != individual.project_id
      errors.add(:individual_id, 'is not from a valid project')
    end
    
    errors.add(:effort, 'must be greater than 0') if effort && effort <= 0
  end
  
  # Set the initial priority to the number of stories (+1 for me).
  def initialize_priority
    highest = Story.find(:first, :order=>'priority desc')
    self.priority = highest ? highest.priority + 1 : 1
  end
  
  # Answer my direct effort rather than that of my tasks.
  def raw_effort
    read_attribute(:effort)
  end
end
