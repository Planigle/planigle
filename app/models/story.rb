require 'csv'

class Story < ActiveRecord::Base
  include Utilities::Text
  include Utilities::CycleTimeObject
  acts_as_paranoid
  belongs_to :project
  belongs_to :team
  belongs_to :release
  belongs_to :iteration
  belongs_to :individual
  belongs_to :epic, :class_name=> "Story", :foreign_key => :story_id
  has_many :stories, :class_name=> "Story", :foreign_key => :story_id, :dependent => :nullify
  has_many :story_values, :dependent => :destroy
  has_many :criteria, -> {order('criteria.priority')}, dependent: :destroy
  has_many :tasks, -> {where(deleted_at: nil).order('tasks.priority')}, dependent: :destroy
  has_many :survey_mappings, :dependent => :destroy
  has_many :comments, -> {where(deleted_at: nil).order('comments.ordering')}, :dependent => :destroy
  audited :except => [:user_priority, :in_progress_at, :done_at]
  
  validates_presence_of     :project_id, :name
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :reason_blocked,         :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :priority, :user_priority, :allow_nil => true # Needed for priority since not set until after check
  validates_numericality_of :status_code
  validate :validate

  before_create :save_relative_priority
  after_create :save_custom_attributes
  before_save :save_relative_priority
  after_save :save_custom_attributes

  StatusMapping = [ 'Not Started', 'In Progress', 'Blocked', 'Done' ]

  @@Created = 0
  cattr_reader :Created

  @@InProgress = 1
  cattr_reader :InProgress

  @@Blocked = 2
  cattr_reader :Blocked

  @@Done = 3
  cattr_reader :Done

  Headers = { 'pid'=>:id, 'epic'=>:story_id, 'name'=>:name, 'description'=>:description, 'acceptance criteria'=>:acceptance_criteria, 'size'=>:effort, 'status'=>:status_code, 'reason blocked'=>:reason_blocked, 'release'=>:release_id, 'iteration'=>:iteration_id, 'team'=>:team_id, 'owner'=>:individual_id, 'public'=>:is_public, 'estimate'=>:estimate, 'actual'=>:actual, 'to do'=>:effort}

  # Assign a priority on creation
  before_create :initialize_defaults

  # Answer a CSV string representing the stories.
  def self.export(current_user, conditions = {})
    CSV.generate(:row_sep => "\n") do |csv|
      attribs = ['PID', 'Epic', 'Name', 'Description', 'Acceptance Criteria', 'Size', 'Estimate', 'To Do', 'Actual', 'Status', 'Reason Blocked', 'Release', 'Iteration', 'Team', 'Owner', 'Public', 'User Rank', 'Lead Time', 'Cycle Time']
      if current_user.project
        if (!current_user.project.track_actuals)
          attribs.delete('Actual')
        end
        story_attributes = current_user.project.story_attributes.where(is_custom: true).includes([:story_attribute_values]).order('name')
        story_attributes.each {|attrib| attribs << attrib.name}
      end
      csv << attribs
      if current_user.project
        stories = get_records(current_user, conditions)
        include_tasks = !conditions.delete(:view_epics)
        stories.each do |story|
          story.export_with_children(conditions, story_attributes, csv, include_tasks)
        end
      end
    end
  end
  
  def export_with_children(conditions, story_attributes, csv, include_tasks)
    @current_conditions = conditions
    export(story_attributes, csv, include_tasks)
    stories.includes([:story_values]).each do |child|
      child.export_with_children(conditions, story_attributes, csv, include_tasks)
    end
  end
  
  # Space the priorities out to prevent bunching.
  def self.update_priorities
    Project.find_each do |project|
      ActiveRecord::Base.connection.update <<-SQL, "Initializing variable"
        set @count:=0
      SQL
      ActiveRecord::Base.connection.update <<-SQL, "Setting priorities"
        update stories,
          (select id, (@count:=@count+10) as rank
          from stories
          where project_id=#{project.id}
          order by priority) sorted
        set stories.priority=sorted.rank where stories.id=sorted.id
      SQL
    end
  end
  
  def export(story_attributes, csv, include_tasks)
    values = [
      'S' + id.to_s,
      epic ? epic.name : '',
      name,
      description,
      acceptance_criteria("\n"),
      effort,
      estimate,
      time]
    if (project.track_actuals)
      values.push actual
    end
    values = values.concat [
      status,
      reason_blocked,
      release ? release.name : '',
      iteration ? iteration.name : '',
      team ? team.name : '',
      individual ? individual.name : '',
      is_public,
      user_priority,
      lead_time,
      cycle_time]
    story_attributes.each do |attrib|
      value = story_values.detect {|story_value| story_value.story_attribute_id == attrib.id}
      if (attrib.value_type == StoryAttribute::List || attrib.value_type == StoryAttribute::ReleaseList) && value
        value = attrib.story_attribute_values.detect {|story_attribute_value| story_attribute_value.id == value.value.to_i}
      end
      values << (value ? value.value : '')
    end
    csv << values
    if include_tasks
      filtered_tasks.each {|task| task.export(csv)}
    end
  end

  # Import from a CSV string representing the stories.
  def self.import(current_user, import_string)
    headers_shown = false
    header_mapping = {}
    errors = []
    prev_object = nil
    CSV.parse(import_string) do |row|
      if !headers_shown
        headers_shown = true
        process_headers(current_user, row, header_mapping)
      else
        prev_object = store_values(current_user, process_values(current_user, row, header_mapping), prev_object ? prev_object.story : nil)
        errors.push(prev_object.errors)
      end
    end
    errors
  end
  
  def story
    self
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

  # Answer an abbreviated label for me.
  def caption
    task_count = tasks.length
    task_status = (tasks.empty? || status_code == @@Created || status_code == @@Done) ? '' : ' - ' + tasks.select {|task| task.status_code == @@Done }.size.to_s + ' of ' + task_count.to_s + ' task' + (task_count == 1 ? '' : 's') + ' done'
    name + '<br/>' + status + task_status
  end
  
  # Answer a url for more details on me.
  def url
    '/planigle/stories/' + id.to_s
  end

  # Answer my acceptance criteria as a string (criteria separated by \r).
  def acceptance_criteria(line_end="\n")
    result = ''
    criteria.each do |criterium|
      if result != ''; result << line_end; end
      if criteria.length > 1; result << '*'; end
      result << criterium.description
      if (criterium.status_code == Criterium.Done)
        result << " (Done)"
      end
    end
    result
  end

  # Set my acceptance criteria based on a string (criteria separated by \r).
  def acceptance_criteria=(new_criteria)
    old_criteria = acceptance_criteria
    if new_criteria != old_criteria
      criteria.each do |criterium|
        criterium.destroy
      end
      criteria.clear
      i = 0
      if new_criteria
        new_criteria.split("\n").each do |criterium|
          criterium = criterium.match(/^\*.*$/) ? criterium[1,criterium.length-1] : criterium
          code = status_code == @@Done ? Criterium.Done : Criterium.Created
          if (match=criterium.match(/^(.*) \(Done\)$/))
            criterium = match[1]
            code = Criterium.Done
          end
          if criterium.strip != ""
            criteria << Criterium.new(:description => criterium, :priority => i, :status_code => code)
            i += 1
          end
        end
      end
      if(!@changed_attributes); @changed_attributes = {}; end
      @changed_attributes['acceptance_criteria'] = [old_criteria, new_criteria]
    end
  end

  # Answer my status in a user friendly format.
  def status
    StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == @@Done
  end
  
  # My estimate is the sum of my tasks.
  def estimate
    filtered_tasks.inject(nil) {|sum, task| task.estimate ? (sum ? sum + task.estimate : task.estimate) : sum}
  end
  
  # My time is the sum of my tasks.
  def time
    filtered_tasks.inject(nil) {|sum, task| task.effort ? (sum ? sum + task.effort : task.effort) : sum}
  end
  
  # My actual is the sum of my tasks.
  def actual
    filtered_tasks.inject(nil) {|sum, task| task.actual ? (sum ? sum + task.actual : task.actual) : sum}
  end
  
  # Create a new story based on this one.
  def split
    next_iteration = self.iteration ? Iteration.where(["start>:start and project_id=:project_id",{start: self.iteration.start, project_id: self.project_id}]).order('start').first : nil
    Story.new(
      :name => increment_name(self.name, self.name + ' Part Two'),
      :project_id => self.project_id,
      :iteration_id => next_iteration ? next_iteration.id : nil,
      :individual_id => self.individual_id,
      :description => self.description,
      :effort => self.effort )
  end

  def current_conditions
    @current_conditions
  end

  def current_conditions= conditions
    @current_conditions = conditions
#    stories.each {|child| child.current_conditions=conditions}
  end
  
  # Override as_json to include tasks.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at, :in_progress_at, :done_at]
    end
    if !options[:include]
      options[:include] = [:story_values, :criteria, :filtered_stories]
    end
    if !options[:methods]
      options[:methods] = [:epic_name, :lead_time, :cycle_time, :filtered_tasks, :comments, :release_name, :iteration_name, :team_name, :individual_name] #:filtered_stories, 
    end
    super(options)
  end

  def release_name
    release == nil ? nil : release.name
  end
  
  def iteration_name
    iteration == nil ? nil : iteration.name
  end
  
  def team_name
    team == nil ? nil : team.name
  end
  
  def individual_name
    individual == nil ? nil : individual.name
  end
  
  def filtered_stories
    stories.sort{|a, b| a.priority <=> b.priority }
  end
  
  def filtered_tasks
    tasks.select{|task| task.matches(self.current_conditions)}
  end

  # Answer the epics for a particular user.
  def self.get_epics(current_user, conditions={})
    modified_conditions = conditions.clone
    modified_conditions[:view_all] = true
    modified_conditions = substitute_conditions(current_user, modified_conditions)
    modified_conditions['tasks'] = {:id => nil}
    result = Story.joins("LEFT JOIN tasks ON tasks.story_id=stories.id").where(modified_conditions).group('stories.id').order('name')
    result.collect{|story| {id: story.id, name: story.name}}
  end

  def self.get_num_pages(current_user, conditions={}, per_page=nil, page=nil)
    if should_paginate(per_page, page, conditions)
      count = get_query(current_user, conditions).count
      count == 0 ? 1 : (count.to_d / per_page).ceil
    else
      1
    end
  end
  
  # Answer the records for a particular user.
  def self.get_records(current_user, conditions={}, per_page=nil, page=nil)
    result = get_query(current_user, conditions)
    if should_paginate(per_page, page, conditions)
      result = result.paginate(:per_page=>per_page, :page=>page)
    end
    result.each{|story| story.current_conditions=conditions}
    result
  end
    
  def self.get_query(current_user, conditions={})
    modified_conditions = conditions.clone
    joins = get_joins(modified_conditions)
    filter_on_individual = modified_conditions.has_key?(:individual_id)
    individual_id = modified_conditions.delete(:individual_id)
    text_filter = modified_conditions.delete(:text)
    modified_conditions = substitute_conditions(current_user, modified_conditions)
    options = {:include => [:criteria, :story_values, :tasks, :iteration, :release, :team, :individual, :stories], :conditions => modified_conditions, :order => 'stories.priority', :joins => joins}
    result = Story
    if options[:include] then result = result.includes(options[:include]) end
    if options[:joins] then result = result.joins(options[:joins]) end
    if options[:conditions] then result = result.where(options[:conditions]) end
    if options[:order] then result = result.order(options[:order]) end
    if filter_on_individual
      individual_id = individual_id ? individual_id.to_i : individual_id
      result = result.select {|story| story.individual_id==individual_id || story.tasks.detect {|task| task.individual_id==individual_id}}
    end
    text_filter ? result.select {|story| story.matches_text(text_filter)} : result
  end

  def self.should_paginate(per_page, page, conditions={})
    per_page && page && !conditions.has_key?(:individual_id) && !conditions.has_key?(:text)
  end
  
  # Update conditions replacing logical values with actual values
  def self.substitute_conditions(current_user, conditions)
    conditions = conditions.clone
    conditions[:project_id] = current_user.project_id
    release = nil
    if conditions[:release_id] == "Current"
      release = Release.find_current(current_user)
      if release
        conditions[:release_id] = release.id
      else
        conditions.delete(:release_id)
      end
    end
    if conditions[:iteration_id] == "Current"
      iteration = Iteration.find_current(current_user, release)
      if iteration
        conditions[:iteration_id] = iteration.id
      else
        conditions.delete(:iteration_id)
      end
    end
    if conditions[:iteration_id] && (conditions[:view_epics] || conditions[:view_all])
      conditions.delete(:iteration_id)
    end
    if conditions[:team_id] == "MyTeam"
      team_id = current_user.team_id
      if team_id && current_user.team.project_id == current_user.project_id
        conditions[:team_id] = team_id
      else
        conditions.delete(:team_id)
      end
    end
    if conditions[:status_code] == "NotDone"
      conditions[:status_code] = [0,1,2]
    end
    if conditions[:view_epics]
      conditions["stories.story_id"] = nil
    elsif !conditions[:view_all]
      conditions["child.id"] = nil
    end
    conditions.delete(:view_all)
    conditions.delete(:view_epics)
    new_conditions = conditions.clone
    conditions.each_pair do |key,value|
      if key.to_s[0..6] == "custom_"
        val = new_conditions.delete(key)
        new_conditions[key.to_s + ".value"] = (val == '' ? nil : val)
      end
    end
    new_conditions
  end
  
  def self.get_joins(conditions)
    joins = ""
    if(!conditions[:view_epics] && !conditions[:view_all])
      joins += "LEFT OUTER JOIN stories as child ON stories.id=child.story_id "
    end
    conditions.each_pair do |key,value|
      key_string = key.to_s
      if key_string[0..6] == "custom_"
        # Use Integer() to make sure that key isn't used for SQL injection
        joins += "LEFT OUTER JOIN story_values AS " + key_string + " ON " + key_string + ".story_id = stories.id AND " + key_string + ".story_attribute_id=" + Integer(key_string[7..key_string.length-1]).to_s + " "
      end
    end
    joins
  end
  
  def self.get_stats(current_individual, conditions)
    stats = {}
    current_individual.project.teams.each{|team|stats[team.id] = get_team_stats(current_individual, conditions, team)}
    stats[0] = get_team_stats(current_individual, conditions, nil)
    stats
  end
  
  def self.get_team_stats(current_individual, conditions, team)
    stats = {:statuses => {}, :iterations => {}}
    [0,1,2,3].each do |status|
      stats[:statuses][status]=Story.get_records(current_individual, {:iteration_id=>'Current',:team_id=>team,:status_code=>status}).inject(0){|result,story|result+(story.effort == nil ? 0 : story.effort)}
    end
    Iteration.get_records(current_individual).each do |iteration|
      if iteration.finish >= DateTime.now
        stats[:iterations][iteration.id]=Story.get_records(current_individual,{:iteration_id=>iteration.id,:team_id=>team}).inject(0){|result,story|result+(story.effort == nil ? 0 : story.effort)}
      end
    end
    stats
  end

  # Answer whether I match the specified text.
  def matches_text(text)
    text = text.downcase
    id_text = text.length > 1 && text[0].chr == 's' && text[1, text.length-1].to_i > 0 ? text[1, text.length-1].to_i : nil
    name.downcase.index(text) ||
    (description && description.downcase.index(text)) ||
    (reason_blocked && reason_blocked.downcase.index(text)) ||
    tasks.detect {|task| task.matches_text(text)} ||
    criteria.detect {|ac| ac.description.downcase.index(text)} ||
    story_values.detect {|sv| sv.story_attribute.value_type<=StoryAttribute::Text && sv.value.downcase.index(text)} ||
    (id_text && id==id_text)
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
    status_code == @@Blocked
  end
  
  # Answer whether I am ready to be accepted (i.e., all my tasks are done).
  def is_ready_to_accept
    !tasks.any? {|task|task.status_code != @@Done}
  end
  
  # Answer whether I am blocked.
  def is_done
    status_code == @@Done
  end
  
  # Notify of changes
  def send_notification(sender, subject, message)
    project.individuals.each do |individual|
      if individual != sender && (!individual.team_id || individual.team_id == team_id)
        individual.send_notification(project, subject, message)
      end
    end
  end
  
  # Answer a string which describes my blocked state.
  def blocked_message
    message = link + " is blocked" + (reason_blocked && reason_blocked != "" ? " because " + reason_blocked : "") + "."
    tasks.each {|task| if task.is_blocked then message += "  "; message += task.blocked_message end}
    message
  end
  
  # Answer a string which describes my blocked state.
  def ready_to_accept_message
    "All tasks for " + link + " are done."
  end
  
  # Answer a string which describes my blocked state.
  def done_message
    link + " is done."
  end
  
  def link
    "<a href='" + external_url + "'>" + name + "</a>"
  end

  def external_url
    "#{Rails.configuration.site_url}/?project_id=" + project.id.to_s() + "&id=" + id.to_s()
  end

  # Override assign_attributes to handle story values set through custom_<StoryAttribute.id>.
  def assign_attributes(new_attributes)
    modified_attributes = {}
    new_attributes.each_pair do |key, value|
      if attrib_id = key.to_s.match(/custom_(.*)/)
        if !@custom_attributes
          @custom_attributes = {}
        end
        @custom_attributes[attrib_id[1]] = value
      elsif key.to_s == 'relative_priority'
        @relative_priority = value
      else
        modified_attributes[key] = value
      end
    end
    super(modified_attributes)
  end

  # When changing projects, blank out my tasks.
  def project_id=(new_project_id)
    old = project_id
    super(new_project_id)
    if (old && old.to_s != new_project_id.to_s)
      tasks.each do |task|
        if (task.individual && !task.individual.projects.include?(Project.find(new_project_id)))
          task.individual_id = nil
          task.save( :validate=> false )
        end
      end
      @delete_custom_attribute_values = true
    end
  end
  
  # Determine the priority by looking at the story before and after
  def determine_priority(before, after)
    if before == ''
      after = Story.find(after).priority
      before = Story.where(["project_id = :project_id and priority < :priority",{project_id: project.id, priority: after}]).order('priority desc').first
      before = before == nil ? after - 2 : before.priority
    elsif after == ''
      before = Story.find(before).priority
      after = Story.where(["project_id = :project_id and priority > :priority", {project_id: project.id, priority: before}]).order('priority').first
      after = after == nil ? before + 2 : after.priority
    else
      before = Story.find(before).priority
      after = Story.find(after).priority
    end
    (before + after) / 2
  end
  
  # Answer the value for an attribute.
  def value_for(attrib)
    if attrib.is_custom
      value = story_values.detect {|val| val.story_attribute == attrib}
      value ? value.value : 0
    else
      case attrib.name
      when 'Release'
        release_id
      when 'Iteration'
        iteration_id
      when 'Team'
        team_id
      when 'Owner'
        individual_id
      when 'Status'
        status_code
      when 'Public'
        is_public ? 1 : 0
      when 'Epic'
        story_id
      else
        nil
      end
    end
  end

  def name_for(attrib)
    if attrib.is_custom
      value = story_values.detect {|val| val.story_attribute == attrib}
      values = attrib.story_attribute_values.select {|val| value != nil && val.id == value.value.to_i}
      values.empty? ? nil : values[0].name
    else
      case attrib.name
      when 'Release'
        release ? release.name : 'No Release'
      when 'Iteration'
        iteration ? iteration.name : 'Backlog'
      when 'Team'
        team ? team.name : 'No Team'
      when 'Owner'
        individual ? individual.name : 'No Owner'
      when 'Status'
        case status_code
        when 0
          'Not Started'
        when 1
          'In Progress'
        when 2
          'Blocked'
        when 3
          'Done'
        end
      when 'Public'
        is_public ? 'True' : 'False'
      when 'Epic'
        epic ? epic.name : 'No Epic'
      else
        nil
      end
    end
  end
    
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

  def invalid_id()
    errors.add(:id, 'is invalid')
  end
  
  def epic_name
    epic ? epic.name : nil;
  end
  
  def update_parent_status
    if epic
      if status_code == 2
        if epic.status_code != 2
          epic.status_code = 2;
          epic.save
        end
      else
        if epic.status_code == 2 && !epic.reason_blocked && !epic.stories.detect{|story| story.status_code == 2}
          if epic.stories.detect{|story| story.status_code > 0}
            epic.status_code = 1;            
          else
            epic.status_code = 0;
          end
          epic.save
        elsif status_code > 0 && epic.status_code == 0
          epic.status_code = 1;
          epic.save
        end
      end
      epic.update_parent_status
    end
  end
    
protected

  # Add custom validation of the status field and relationships to give a more specific message.
  def validate
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, 'is invalid')
    end
    
    if story_id && !Story.find_by_id(story_id)
      errors.add(:epic, 'is invalid')
    elsif epic && project_id != epic.project_id
      errors.add(:epic, 'is not from a valid project')
    elsif story_id != nil && story_id == id
      errors.add(:epic, 'cannot be its own epic')
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
      errors.add(:owner, 'is invalid')
    elsif individual && !individual.projects.detect {|project| project.id == project_id}
      errors.add(:owner, 'is not from a valid project')
    end
    
    validate_custom_attributes
  end

  # Validate any unsaved custom attributes.
  def validate_custom_attributes
    if @custom_attributes && !@delete_custom_attribute_values
      @custom_attributes.each_pair do |key, value|
        attrib = project ? project.story_attributes.where(id: key, is_custom: true).first : nil
        if attrib && (attrib.value_type != StoryAttribute::List || value == "" || value == nil || attrib.story_attribute_values.where(id: value).first) && (attrib.value_type != StoryAttribute::ReleaseList || value == "" || value == nil || attrib.story_attribute_values.where(id: value, release_id: release_id).first)
        elsif !attrib
          errors.add(:base, "Invalid attribute")
        else
          errors.add(attrib.name.to_sym, "is invalid")
        end
      end
    end
  end

  # Save relative priority.
  def save_relative_priority
    if @relative_priority
      match = @relative_priority.match(/(.*),(.*)/)
      self.priority = determine_priority(match[1],match[2])
      @relative_priority = nil
    end    
  end
  
  # Save any custom attributes.
  def save_custom_attributes
    if @delete_custom_attribute_values
      story_values.each {|val| val.destroy}      
    elsif @custom_attributes
      @custom_attributes.each_pair do |key, value|
        attrib = project.story_attributes.where(id: key, is_custom: true).first
        if attrib
          if attrib.is_date && value != nil && value.strip != ''
            value = value.gsub(/\//, '-') # Excel likes to substitute these
            splits = value.split('-')
            if (splits[0].length == 1)
              splits[0] = '0' +  splits[0];
            end
            if (splits.length > 1 && splits[1].length == 1)
              splits[0] = '0' +  splits[1];
            end
            value = splits.join('-')
          end
          val = story_values.where(story_attribute_id: key).first
          if val && value != nil and value != ""
            val.value = value
            val.save( :validate=> false )
          elsif val
            val.destroy
          elsif value != nil and value != ""
            story_values << StoryValue.new({:story_attribute_id => attrib.id, :value => value})
          end
        else
          errors.add('custom_' + id.to_s, "Invalid attribute")
        end
      end
    end
    @delete_custom_attribute_values = nil
    @custom_attributes = nil
  end
  
  # Set the initial priority to the number of stories (+1 for me).  Set public to false if not set.
  def initialize_defaults
    if !self.priority
      highest = Story.order('priority desc').first
      self.priority = highest ? highest.priority + 1 : 1
    end
  end

private

  # Process the import headers given a row and a hash to populate with index=>attribute.
  def self.process_headers(current_user, row, header_mapping)
    i = 0
    row.each do |value|
      if (value)
        down = value.downcase;
        if Headers.has_key?(down)
          header_mapping[i] = Headers[down]
        else # Check for custom attribute
          header_mapping[i] = :ignore
          current_user.selected_project.story_attributes.where(is_custom: true).each do |attrib|
            if attrib.name.downcase == down
              header_mapping[i] = "custom_" + attrib.id.to_s
              break;
            end
          end
        end
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
            when :story_id then value = find_object_id(value, Story, ['name = ? and project_id = ?', value, current_user.project_id])
            when :team_id then value = find_object_id(value, Team, ['name = ? and project_id = ?', value, current_user.project_id])
            when :individual_id then value = find_object_id(value, Individual, ["concat(first_name, ' ', last_name) = ? and projects.id = ?", value, current_user.project_id], :projects)
            when :release_id then temp = find_object_id(value, Release, ['name = ? and project_id = ?', value, current_user.project_id]); value = temp == -1 ? value = find_object_id(value, Release, ['name like ? and project_id = ?', value.to_s+'%', current_user.project_id]) : temp
            when :iteration_id then value = find_object_id(value, Iteration, ['name = ? and project_id = ?', value, current_user.project_id])
            when :status_code then value = status_code_mapping.has_key?(value) ? status_code_mapping[value] : -1
            when :effort then value = value ? value.to_f : value
            else
              if attrib = header.to_s.match(/custom_(.*)/)
                attribute = current_user.selected_project.story_attributes.where(id: attrib[1]).first;
                if attribute && (attribute.value_type == StoryAttribute::List || attribute.value_type == StoryAttribute::ReleaseList)
                  if !value || value == ""
                    value = nil
                  else
                    attrib_value = attribute.story_attribute_values.where(value: value).first
                    value = attrib_value ? attrib_value.id : -1
                  end
                end
              end
          end
          values[header] = value
        end
      end
    end
    values
  end
  
  # Store the values for the current_user.
  def self.store_values(current_user, values, prev_story)
    object = nil
    if values.has_key?(:id) && values[:id]
      id = values[:id].downcase
      if (id[0,1] == 't')
        remove_story_values(values)
        if (id.size == 1 && prev_story)
          values.delete(:id)
          values[:story_id] = prev_story.id
          object = Task.create(values)
        else
          values[:id] = id[1..id.size-1]
          object = update_task(current_user, values)
        end
      else
        if (id[0,1] == 's')
          values[:id] = id[1..id.size-1]
        end
        remove_task_values(values)
        if (id == 's')
          values[:project_id] = current_user.project_id
          values.delete(:id)
          object = Story.create(values)
        else
          object = update_story(current_user, values)
        end
      end
    else
      values[:project_id] = current_user.project_id
      values.delete(:id)
      remove_task_values(values)
      object = Story.create(values)
    end
    if !object
      object = new
      object.invalid_id
    end
    object
  end

  def self.update_story(current_user, values)
    story = Story.where(id: values[:id]).first
    if story && story.authorized_for_update?(current_user)
      story.update_attributes(values)
    elsif story
      story.errors.add(:id, "is invalid")
    end
    story
  end
  
  def self.remove_story_values(values)
    values.delete(:story_id)
    values.delete(:acceptance_criteria)
    values.delete(:size)
    values.delete(:release_id)
    values.delete(:iteration_id)
    values.delete(:team_id)
    values.delete(:is_public)
    
    custom_attributes = []
    values.clone.each_pair do |key, value|
      if key.to_s[0..6] == "custom_"
        values.delete(key)
      end
    end
  end
  
  def self.remove_task_values(values)
    values.delete(:estimate)
    values.delete(:actual)
  end

  def self.update_task(current_user, values)
    task = Task.where(id: values[:id]).first
    if task && task.story.authorized_for_update?(current_user)
      task.update_attributes(values)
    elsif task
      task.errors.add(:id, "is invalid")
    end
    task
  end

  # Find the object id given a value, a class and conditions.
  def self.find_object_id(value, klass, conditions, joins=nil)
    if !value || value == ""; return nil; end
    if joins
      object = klass.joins(joins).where(conditions).first
    else
      object = klass.where(conditions).first
    end
    object ? object.id : -1
  end
end