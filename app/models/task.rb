class Task < ActiveRecord::Base
  include Utilities::CycleTimeObject
  acts_as_paranoid
  belongs_to :individual
  belongs_to :story
  belongs_to :status
  audited :except => [:story_id, :in_progress_at, :done_at]
  
  validates_presence_of     :name, :story_id, :status_id
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 20480, :allow_nil => true
  validates_length_of       :reason_blocked,         :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :actual, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :estimate, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :priority, :allow_nil => true # Needed for priority since not set until after check
  validate :validate

  before_validation :initialize_status
  
  # Assign a priority on creation
  before_create :initialize_defaults
  
  def status_code
    status ? status.status_code : -1
  end
  
  def statuses
    project ? project.task_statuses : []
  end
  
  # Answer whether I am blocked.
  def is_blocked
    status_code == Status.Blocked
  end
  
  # Answer whether I am done.
  def is_done
    status_code == Status.Done
  end

  def project
    story ? story.project : nil
  end
  
  # Override as_json to include lead and cycle time.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at, :in_progress_at, :done_at]
    end
    if !options[:methods]
      options[:methods] = [:lead_time, :cycle_time, :individual_name, :status_code]
    end
    super(options)
  end

  def individual_name
    individual == nil ? nil : individual.name
  end
  
  def export(csv)
    values = [
      'T' + id.to_s,
      '', # epic
      name,
      description,
      '', # acceptance criteria
      '', # size
      estimate,
      effort]
    if (project.track_actuals)
      values.push actual
    end
    values = values.concat [
      status.name,
      reason_blocked,
      '', # release
      '', # iteration
      '', # team
      individual ? individual.name : '',
      '', # public
      '', # user rank
      lead_time,
      cycle_time]
    project.story_attributes.where(is_custom: true).order('name').each do |attrib|
      values << ''
    end
    csv << values
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
  
  # Answer a string which describes my blocked state.
  def blocked_message
    name + " is blocked" + (reason_blocked && reason_blocked != "" ? " because " + reason_blocked : "") + "."
  end
  
  # Set the initial priority to the number of tasks (+1 for me).
  def initialize_defaults
    if !self.priority
      highest = story.tasks.order('priority desc').first
      self.priority = highest ? highest.priority + 1 : 1
    end
  end
  
  def initialize_status
    if !self.status && story
      self.status_code = Status.Created
    end
  end
  
  # Answer whether I match the specified text.
  def matches_text(text)
      text = text.downcase
      id_text = text.length > 1 && text[0].chr == 't' && text[1, text.length-1].to_i > 0 ? text[1, text.length-1].to_i : nil
      name.downcase.index(text) ||
      (description && description.downcase.index(text)) ||
      (reason_blocked && reason_blocked.downcase.index(text)) ||
      (id_text && id==id_text)
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

  def matches(cond)
    !cond || (matches_individual(cond) && matches_status(cond))
  end

  def update_parent_status
    if is_blocked
      if !story.is_blocked
        story.status_code = Status.Blocked
        story.save
      end
    elsif story.is_blocked && !story.reason_blocked && !story.tasks.detect{|task| task.is_blocked}
      if story.tasks.detect{|task| task.status_code > Status.Created}
        story.status_code = Status.InProgress
      else
        story.status_code = Status.Created
      end
      story.save
    elsif status_code > Status.Created && story.status_code == Status.Created
      story.status_code = Status.InProgress
      story.save
    end
    story.update_parent_status
  end

  def equivalent_status(status)
    new_status = statuses.detect{|candidate| candidate.name=status.name && candidate.status_code=status.status_code}
    if !new_status
      new_status = statuses.detect{|candidate| candidate.status_code=status.status_code}
    end
    new_status
  end
  
  # Override assign_attributes to handle story values set through custom_<StoryAttribute.id>.
  def assign_attributes(new_attributes)
    if new_attributes.has_key?(:story_id) || new_attributes.has_key?('story_id')   # Set first so we can use it
      self.story_id = new_attributes[:story_id] || new_attributes['story_id']
    end
    super(new_attributes)
  end

protected

  def matches_individual(cond)
    if !cond || !cond.include?(:individual_id)
      true
    else
      cond[:individual_id] ? cond[:individual_id].to_i == individual_id : !individual_id
    end
  end
  
  def matches_status(cond)
    if !cond || !cond.include?(:status_code)
      true
    elsif cond[:status_code] == "NotDone"
      [0,1,2].include?(status_code)
    else
      cond[:status_code].to_i == status_code
    end
  end
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate
    if @invalid_status || !status || !(statuses.detect {|task_status| task_status.id == status.id})
      errors.add(:status_code, 'is invalid')
    end
    
    if individual_id && !Individual.find_by_id(individual_id)
      errors.add(:owner, 'is invalid')
    elsif individual && !individual.projects.detect {|project| project.id == story.project_id}
      errors.add(:owner, 'is not from a valid project')
    end
    
    if story_id && !Story.find_by_id(story_id)
      errors.add(:story_id, 'is invalid')
    end
  end
end