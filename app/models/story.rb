class Story < ActiveRecord::Base
  include Utilities::Text
  belongs_to :project
  belongs_to :release
  belongs_to :iteration
  belongs_to :individual
  has_many :tasks, :dependent => :destroy
  has_many :survey_mappings, :dependent => :destroy
  
  validates_presence_of     :project_id, :name
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :acceptance_criteria,    :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true
  validates_numericality_of :priority, :user_priority, :allow_nil => true # Needed for priority since not set until after check
  validates_numericality_of :status_code

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  attr_accessible :name, :description, :acceptance_criteria, :effort, :status_code, :release_id, :iteration_id, :individual_id, :project_id, :is_public, :priority, :user_priority

  # Assign a priority on creation
  before_create :initialize_defaults

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # Map user displayable terms to the internal status codes.
  def self.status_code_mapping
    i = -1
    valid_status_values.collect { |val| i+=1;[val, i] }
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
  def calculatedEffort
    effort ? effort : tasks.inject(nil) {|sum, task| task.effort ? (sum ? sum + task.effort : task.effort) : sum } # Fewer queries than sum if tasks included
  end
  
  # Create a new story based on this one.
  def split
    next_iteration = self.iteration ? Iteration.find(:first, :conditions => ["start>? and project_id=?", self.iteration.start, self.project_id], :order => 'start') : nil
    Story.new(
      :name => increment_name(self.name, self.name + ' Part Two'),
      :project_id => self.project_id,
      :iteration_id => next_iteration ? next_iteration.id : nil,
      :individual_id => self.individual_id,
      :description => self.description,
      :acceptance_criteria => self.acceptance_criteria,
      :effort => self.effort )
  end
  
  # Override to_xml to include tasks.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:tasks]
    end
    super(options)
  end
  
  # Only project users or higher can create stories.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    elsif current_user.role <= Individual::ProjectUser && current_user.project_id == project_id
      true
    else
      false
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
      when Individual::ProjectUser then current_user.project_id == project_id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
      when Individual::ProjectUser then current_user.project_id == project_id
      else false
    end
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
  
  # Set the initial priority to the number of stories (+1 for me).  Set public to false if not set.
  def initialize_defaults
    highest = Story.find(:first, :order=>'priority desc')
    self.priority = highest ? highest.priority + 1 : 1
  end
end
