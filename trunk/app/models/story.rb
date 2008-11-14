require 'faster_csv'

class Story < ActiveRecord::Base
  include Utilities::Text
  belongs_to :project
  belongs_to :team
  belongs_to :release
  belongs_to :iteration
  belongs_to :individual
  has_many :tasks, :dependent => :destroy
  has_many :survey_mappings, :dependent => :destroy
  
  validates_presence_of     :project_id, :name
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :acceptance_criteria,    :maximum => 4096, :allow_nil => true
  validates_length_of       :reason_blocked,         :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true, :greater_than => 0
  validates_numericality_of :priority, :user_priority, :allow_nil => true # Needed for priority since not set until after check
  validates_numericality_of :status_code

  StatusMapping = [ 'Created', 'In Progress', 'Blocked', 'Done' ]
  Created = 0
  InProgress = 1
  Blocked = 2
  Done = 3

  Headers = { 'pid'=>:id, 'name'=>:name, 'description'=>:description, 'acceptance criteria'=>:acceptance_criteria, 'effort'=>:effort, 'status'=>:status_code, 'reason blocked'=>:reason_blocked, 'release'=>:release_id, 'iteration'=>:iteration_id, 'team'=>:team_id, 'owner'=>:individual_id, 'public'=>:is_public}

  attr_accessible :name, :description, :acceptance_criteria, :effort, :status_code, :release_id, :iteration_id, :individual_id, :project_id, :is_public, :priority, :user_priority, :team_id, :reason_blocked

  # Assign a priority on creation
  before_create :initialize_defaults

  # Answer a CSV string representing the stories.
  def self.export(current_user)
    FasterCSV.generate(:row_sep => "\n") do |csv|
      csv << ['PID', 'Name', 'Description', 'Acceptance Criteria', 'Size', 'Time', 'Status', 'Reason Blocked', 'Release', 'Iteration', 'Team', 'Owner', 'Public', 'User Rank']
      get_records(current_user).each {|story| story.export(csv)}
    end
  end
  
  # Export given an instance of FasterCSV.
  def export(csv)
    csv << [
      id,
      name,
      description,
      acceptance_criteria,
      effort,
      calculated_effort,
      StatusMapping[status_code],
      reason_blocked,
      release ? release.name : '',
      iteration ? iteration.name : '',
      team ? team.name : '',
      individual ? individual.name : '',
      is_public,
      user_priority]
  end

  # Import from a CSV string representing the stories.
  def self.import(current_user, import_string)
    headers_shown = false
    header_mapping = {}
    errors = [] 
    FasterCSV.parse(import_string) do |row|
      if !headers_shown
        headers_shown = true
        process_headers(row, header_mapping)
      else
        errors.push(store_values(current_user, process_values(current_user, row, header_mapping)))
      end
    end
    errors
  end
  
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

  # Answer my status in a user friendly format.
  def status
    StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == Done
  end
  
  # My effort is either my value (if set) or the sum of my tasks.
  def calculated_effort
    task_effort = tasks.inject(nil) {|sum, task| task.effort ? (sum ? sum + task.effort : task.effort) : sum}
    task_effort != nil ? task_effort : effort
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

  # Answer the records for a particular user.
  def self.get_records(current_user, iteration_id=nil)
    if iteration_id
      if current_user.role >= Individual::ProjectAdmin or current_user.project_id
        Story.find(:all, :include => :tasks, :conditions => ["iteration_id = ? and project_id = ?", iteration_id, current_user.project_id], :order => 'priority')
      else
        Story.find(:all, :include => :tasks, :conditions => ["iteration_id = ?", iteration_id], :order => 'priority')
      end
    else
      if current_user.role >= Individual::ProjectAdmin or current_user.project_id
        Story.find(:all, :include => :tasks, :conditions => ["project_id = ?", current_user.project_id], :order => 'priority')
      else
        Story.find(:all, :include => :tasks, :order => 'priority')
      end
    end
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

  # Answer whether I am blocked.
  def is_blocked
    status_code == Blocked
  end
  
  # Answer a string which describes my blocked state.
  def blocked_message
    message = name + " is blocked" + (reason_blocked && reason_blocked != "" ? " because " + reason_blocked : "") + "."
    tasks.each {|task| if task.is_blocked then message += "  "; message += task.blocked_message end}
    message
  end

protected

  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, 'is invalid')
    end
    
    if release_id && !Release.find_by_id(release_id)
      errors.add(:release, 'is invalid')
    elsif release && project_id != release.project_id
      errors.add(:release, 'is not from a valid project')
    end
    
    if iteration_id && !Iteration.find_by_id(iteration_id)
      errors.add(:iteration, 'is invalid')
    elsif iteration && project_id != iteration.project_id
      errors.add(:iteration, 'is not from a valid project')
    end
    
    if team_id && !Team.find_by_id(team_id)
      errors.add(:team, 'is invalid')
    elsif team && project_id != team.project_id
      errors.add(:team, 'is not from a valid project')
    end
    
    if individual_id && !Individual.find_by_id(individual_id)
      errors.add(:individual, 'is invalid')
    elsif individual && project_id != individual.project_id
      errors.add(:individual, 'is not from a valid project')
    end
  end
  
  # Set the initial priority to the number of stories (+1 for me).  Set public to false if not set.
  def initialize_defaults
    if !self.priority
      highest = Story.find(:first, :order=>'priority desc')
      self.priority = highest ? highest.priority + 1 : 1
    end
  end

private

  # Process the import headers given a row and a hash to populate with index=>attribute.
  def self.process_headers(row, header_mapping)
    i = 0
    row.each do |value|
      if (value)
        down = value.downcase;
        header_mapping[i] = Headers.has_key?(down) ? Headers[down] : :ignore;
      end
      i += 1
    end
  end

  # Process the import values given a row and a hash of headers mapping index=>attribute.  Return a hash
  # of values (mapping attribute=>value).
  def self.process_values(current_user, row, header_mapping)
    values = {}
    (0..row.length-1).each do |i|
      if i < header_mapping.length  # ignore columns with no header
        header = header_mapping[i]
        value = row[i]
        if (header && header != :ignore)
          case header
            when :team_id then value = find_object_id(value, Team, ['name = ? and project_id = ?', value, current_user.project_id])
            when :individual_id then value = find_object_id(value, Individual, ["concat(first_name, ' ', last_name) = ? and project_id = ?", value, current_user.project_id])
            when :release_id then temp = find_object_id(value, Release, ['name = ? and project_id = ?', value, current_user.project_id]); value = temp == -1 ? value = find_object_id(value, Release, ['name like ? and project_id = ?', value.to_s+'%', current_user.project_id]) : temp
            when :iteration_id then value = find_object_id(value, Iteration, ['name = ? and project_id = ?', value, current_user.project_id])
            when :status_code then value = status_code_mapping.has_key?(value) ? status_code_mapping[value] : -1
            when :effort then value = value ? value.to_f : value
          end
          values[header] = value
        end
      end
    end
    values
  end
  
  # Store the values for the current_user.
  def self.store_values(current_user, values)
    story = nil
    if values.has_key?(:id) && values[:id]
      story = Story.find(:first, :conditions => ['id = ?', values[:id]])
      if story && story.authorized_for_update?(current_user)
        story.update_attributes(values)
      elsif story
        story.errors.add(:id, "is invalid")
      end
    else
      values[:project_id] = current_user.project_id
      story = Story.create(values)
    end
    if story
      story.errors
    else
      err = ActiveRecord::Errors.new(new)
      err.add(:id, "is invalid")
      err
    end
  end

  # Find the object id given a value, a class and conditions.
  def self.find_object_id(value, klass, conditions)
    if !value; return nil; end
    object = klass.find(:first, :conditions => conditions)
    object ? object.id : -1
  end
end
