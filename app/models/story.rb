require 'faster_csv'

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
  has_many :criteria, :dependent => :destroy, :order => 'criteria.priority'
  has_many :tasks, :dependent => :destroy, :order => 'tasks.priority', :conditions => "tasks.deleted_at IS NULL"
  has_many :all_tasks, :class_name => "Task"
  has_many :survey_mappings, :dependent => :destroy
  attr_accessible :name, :description, :acceptance_criteria, :effort, :status_code, :release_id, :iteration_id, :individual_id, :project_id, :is_public, :priority, :user_priority, :team_id, :reason_blocked, :story_id
  acts_as_audited :except => [:user_priority, :in_progress_at, :done_at]
  
  validates_presence_of     :project_id, :name
  validates_length_of       :name,                   :maximum => 250, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :reason_blocked,         :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :priority, :user_priority, :allow_nil => true # Needed for priority since not set until after check
  validates_numericality_of :status_code

  before_create :save_relative_priority
  after_create :save_custom_attributes
  before_save :save_relative_priority
  after_save :save_custom_attributes

  StatusMapping = [ 'Not Started', 'In Progress', 'Blocked', 'Done' ]
  Created = 0
  InProgress = 1
  Blocked = 2
  Done = 3

  Headers = { 'pid'=>:id, 'epic'=>:story_id, 'name'=>:name, 'description'=>:description, 'acceptance criteria'=>:acceptance_criteria, 'size'=>:effort, 'status'=>:status_code, 'reason blocked'=>:reason_blocked, 'release'=>:release_id, 'iteration'=>:iteration_id, 'team'=>:team_id, 'owner'=>:individual_id, 'public'=>:is_public, 'estimate'=>:estimate, 'actual'=>:actual, 'to do'=>:effort}

  # Assign a priority on creation
  before_create :initialize_defaults

  # Answer a CSV string representing the stories.
  def self.export(current_user, conditions = {})
    FasterCSV.generate(:row_sep => "\n") do |csv|
      attribs = ['PID', 'Epic', 'Name', 'Description', 'Acceptance Criteria', 'Size', 'Estimate', 'To Do', 'Actual', 'Status', 'Reason Blocked', 'Release', 'Iteration', 'Team', 'Owner', 'Public', 'User Rank', 'Lead Time', 'Cycle Time']
      if (current_user.project)
        if (!current_user.project.track_actuals)
          attribs.delete('Actual')
        end
        current_user.project.story_attributes.find(:all, :conditions => {:is_custom => true}, :order => :name).each {|attrib| attribs << attrib.name}
      end
      csv << attribs
      get_records(current_user, conditions).each do |story|
        story.current_conditions = conditions
        story.export(csv)
      end
    end
  end
  
  # Space the priorities out to prevent bunching.
  def self.update_priorities
    Project.find(:all).each do |project|
      project.connection.update <<-SQL, "Initializing variable"
        set @count:=0
      SQL
      project.connection.update <<-SQL, "Setting priorities"
        update stories,
          (select id, (@count:=@count+10) as rank
          from stories
          where project_id=#{project.id}
          order by priority) sorted
        set stories.priority=sorted.rank where stories.id=sorted.id
      SQL
    end
  end
  
  # Export given an instance of FasterCSV.
  def export(csv)
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
    project.story_attributes.find(:all, :conditions => {:is_custom => true}, :order => :name).each do |attrib|
      value = story_values.find(:first, :conditions => {:story_attribute_id => attrib.id})
      if (attrib.value_type == StoryAttribute::List || attrib.value_type == StoryAttribute::ReleaseList) && value
        value = attrib.story_attribute_values.find(:first, :conditions => {:id => value.value})
      end
      values << (value ? value.value : '')
    end
    csv << values
    filtered_tasks.each {|task| task.export(csv)}
  end

  # Import from a CSV string representing the stories.
  def self.import(current_user, import_string)
    headers_shown = false
    header_mapping = {}
    errors = []
    prev_object = nil
    FasterCSV.parse(import_string) do |row|
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
    task_status = (tasks.empty? || status_code == Created || status_code == Done) ? '' : ' - ' + tasks.select {|task| task.status_code == Done }.size.to_s + ' of ' + task_count.to_s + ' task' + (task_count == 1 ? '' : 's') + ' done'
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
      if (criterium.status_code == Criterium::Done)
        result << " (Done)"
      end
    end
    result
  end

  # Set my acceptance criteria based on a string (criteria separated by \r).
  def acceptance_criteria=(new_criteria)
    old_criteria = acceptance_criteria
    criteria.each do |criterium|
      criterium.destroy
    end
    criteria.clear
    i = 0
    if new_criteria
      new_criteria.split("\n").each do |criterium|
        if criterium.strip != ""
          criterium = criterium.match(/^\*.*$/) ? criterium[1,criterium.length-1] : criterium
          code = status_code == Done ? Criterium::Done : Criterium::Created
          if (match=criterium.match(/^(.*) \(Done\)$/))
            criterium = match[1]
            code = Criterium::Done
          end
          criteria << Criterium.new(:description => criterium, :priority => i, :status_code => code)
          i += 1
        end
      end
    end
    if new_criteria != old_criteria
      changed_attributes['acceptance_criteria'] = [old_criteria, new_criteria]
    end
  end

  # Answer my status in a user friendly format.
  def status
    StatusMapping[status_code]
  end

  # Answer true if I have been accepted.
  def accepted?
    self.status_code == Done
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
    next_iteration = self.iteration ? Iteration.find(:first, :conditions => ["start>? and project_id=?", self.iteration.start, self.project_id], :order => 'start') : nil
    newStory = Story.new(
      :name => increment_name(self.name, self.name + ' Part Two'),
      :project_id => self.project_id,
      :iteration_id => next_iteration ? next_iteration.id : nil,
      :individual_id => self.individual_id,
      :description => self.description,
      :effort => self.effort )
    newStory.in_progress_at = self.in_progress_at
    newStory
  end

  def current_conditions
    @current_conditions
  end

  def current_conditions= conditions
    @current_conditions = conditions
  end
  
  # Override to_xml to include tasks.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:story_values, :criteria]
    end
    if !options[:methods]
      options[:methods] = [:acceptance_criteria, :epic_name, :lead_time, :cycle_time]
    end
    if !options[:procs]
      story_proc = Proc.new {|opt| filtered_stories_as_xml(opt[:builder])}
      task_proc = Proc.new {|opt| filtered_tasks_as_xml(opt[:builder])}
      options[:procs] = [story_proc, task_proc]
    end
    super(options)
  end
  
  def filtered_stories
    stories
  end
  
  def filtered_stories_as_xml(builder)
    builder.method_missing("filtered-stories".to_sym) do
      filtered_stories.each do |story|
        story.to_xml({:builder => builder, :skip_instruct => true, :root => :filtered_story})
      end
    end
  end
  
  def filtered_tasks
    tasks.select{|task| task.matches(self.current_conditions)}
  end
  
  def filtered_tasks_as_xml(builder)
    builder.method_missing("filtered-tasks".to_sym) do
      filtered_tasks.each do |task|
        task.to_xml({:builder => builder, :skip_instruct => true, :root => :filtered_task})
      end
    end
  end

  # Answer whether records have changed.
  def self.have_records_changed(current_user, time)
    Story.count_with_deleted(:include => [:all_tasks], :conditions => ["(stories.updated_at >= ? or stories.deleted_at >= ? or tasks.updated_at >= ? or tasks.deleted_at >= ?) and stories.project_id = ?", time, time, time, time, current_user.project_id]) > 0
  end

  # Answer the records for a particular user.
  def self.get_records(current_user, conditions={}, per_page=nil, page=nil)
    modified_conditions = conditions.clone
    joins = get_joins(modified_conditions)
    filter_on_individual = modified_conditions.has_key?(:individual_id)
    individual_id = modified_conditions.delete(:individual_id)
    text_filter = modified_conditions.delete(:text)
    modified_conditions = substitute_conditions(current_user, modified_conditions)
    options = {:include => [:criteria, :story_values, :tasks], :conditions => modified_conditions, :order => 'stories.priority', :joins => joins}
    should_paginate = per_page && page && !filter_on_individual && !text_filter
    if should_paginate
      options[:per_page] = per_page
      options[:page] = page
    end
    result = should_paginate ? Story.paginate(options) : Story.find(:all, options)
    if filter_on_individual
      individual_id = individual_id ? individual_id.to_i : individual_id
      result = result.select {|story| story.individual_id==individual_id || story.tasks.detect {|task| task.individual_id==individual_id}}
    end
    result = text_filter ? result.select {|story| story.matches_text(text_filter)} : result
    result.each{|story| story.current_conditions=conditions}
    result
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
    if conditions[:iteration_id] && conditions[:view_epics]
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
    else
      conditions["child.id"] = nil
    end
    conditions.delete(:view_epics)
    new_conditions = conditions.clone
    conditions.each_pair do |key,value|
      if key.to_s[0..6] == "custom_"
        new_conditions[key.to_s + ".value"] = new_conditions.delete(key)
      end
    end
    new_conditions
  end
  
  def self.get_joins(conditions)
    joins = ""
    if(!conditions[:view_epics])
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
    status_code == Blocked
  end
  
  # Answer whether I am ready to be accepted (i.e., all my tasks are done).
  def is_ready_to_accept
    !tasks.any? {|task|task.status_code != Done}
  end
  
  # Answer whether I am blocked.
  def is_done
    status_code == Done
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
    "#{config_option(:site_url)}/?project_id=" + project.id.to_s() + "&id=" + id.to_s()
  end

  # Override attributes= to handle story values set through custom_<StoryAttribute.id>.
  def attributes=(new_attributes, guard_protected_attributes = true)
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
    super(modified_attributes, guard_protected_attributes)
  end

  # When changing projects, blank out my tasks.
  def project_id=(new_project_id)
    old = project_id
    super(new_project_id)
    if (old && old.to_s != new_project_id.to_s)
      tasks.each do |task|
        if (task.individual && !task.individual.projects.include?(Project.find(new_project_id)))
          task.individual_id = nil
          task.save(false)
        end
      end
      @delete_custom_attribute_values = true
    end
  end
  
  # Determine the priority by looking at the story before and after
  def determine_priority(before, after)
    if before == ''
      after = Story.find(after).priority
      before = Story.find(:first, :conditions => ['project_id = ? and priority < ?', project.id, after], :order => 'priority desc')
      before = before == nil ? after - 2 : before.priority
    elsif after == ''
      before = Story.find(before).priority
      after = Story.find(:first, :conditions => ['project_id = ? and priority > ?', project.id, before], :order => 'priority')
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
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

  def invalid_id()
    errors.add(:id, 'is invalid')
  end
  
  def epic_name
    epic ? epic.name : nil;
  end
    
protected

  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if status_code < 0 || status_code >= StatusMapping.length
      errors.add(:status_code, 'is invalid')
    end
    
    if story_id && !Story.find_by_id(story_id)
      errors.add(:epic, 'is invalid')
    elsif epic && project_id != epic.project_id
      errors.add(:epic, 'is not from a valid project')
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
        attrib = project ? project.story_attributes.find(:first, :conditions => {:id => key, :is_custom => true}) : nil
        if attrib && (attrib.value_type != StoryAttribute::List || value == "" || value == nil || attrib.story_attribute_values.find(:first, :conditions => {:id => value})) && (attrib.value_type != StoryAttribute::ReleaseList || value == "" || value == nil || attrib.story_attribute_values.find(:first, :conditions => {:id => value, :release_id => release_id}))
        elsif !attrib
          errors.add_to_base("Invalid attribute")
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
        attrib = project.story_attributes.find(:first, :conditions => {:id => key, :is_custom => true})
        val = story_values.find(:first, :conditions => {:story_attribute_id => key})
        if val && value != nil and value != ""
          val.value = value
          val.save(false)
        elsif val
          val.destroy
        elsif value != nil and value != ""
          story_values << StoryValue.new({:story_attribute_id => attrib.id, :value => value})
        end
      end
    end
    @delete_custom_attribute_values = nil
    @custom_attributes = nil
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
  def self.process_headers(current_user, row, header_mapping)
    i = 0
    row.each do |value|
      if (value)
        down = value.downcase;
        if Headers.has_key?(down)
          header_mapping[i] = Headers[down]
        else # Check for custom attribute
          header_mapping[i] = :ignore
          current_user.selected_project.story_attributes.find(:all, :conditions => {:is_custom => true}).each do |attrib|
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
                attribute = current_user.selected_project.story_attributes.find(:first, :conditions => {:id => attrib[1]});
                if attribute && (attribute.value_type == StoryAttribute::List || attribute.value_type == StoryAttribute::ReleaseList)
                  if !value || value == ""
                    value = nil
                  else
                    attrib_value = attribute.story_attribute_values.find(:first, :conditions => {:value => value})
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
        if (id.size == 1 && prev_story)
          values[:story_id] = prev_story.id
          object = Task.create(values)
        else
          values.delete(:story_id) # don't use epic
          values[:id] = id[1..id.size-1]
          object = update_task(current_user, values)
        end
      else
        if (id[0,1] == 's')
          values[:id] = id[1..id.size-1]
        end
        object = update_story(current_user, values)
      end
    else
      values[:project_id] = current_user.project_id
      object = Story.create(values)
    end
    if !object
      object = new
      object.invalid_id
    end
    object
  end

  def self.update_story(current_user, values)
    story = Story.find(:first, :conditions => ['id = ?', values[:id]])
    if story && story.authorized_for_update?(current_user)
      story.update_attributes(values)
    elsif story
      story.errors.add(:id, "is invalid")
    end
    story
  end

  def self.update_task(current_user, values)
    task = Task.find(:first, :conditions => ['id = ?', values[:id]])
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
      object = klass.find(:first, :conditions => conditions, :joins => joins)
    else
      object = klass.find(:first, :conditions => conditions)
    end
    object ? object.id : -1
  end
end