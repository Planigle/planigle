class Total < ActiveRecord::Base
  belongs_to :team

  @abstract_class = true

  # Summarize an object.
  def self.summarize_for(object)
    (Array.new(object.project.teams) << nil).collect do |team|
      created = 0
      in_progress = 0
      done = 0
      blocked = 0
      find_items(object, team).each do |item|
        effort = item.effort
        effort = effort != nil ? effort : 0
        case item.status_code
          when Story::Created then created += effort
          when Story::InProgress then in_progress += effort
          when Story::Blocked then blocked += effort
          else done += effort
        end
      end
      capture( object.id, team ? team.id : nil, created, in_progress, done, blocked)
    end
  end
  
  # Create or update summarized data.
  def self.capture(id, team_id, created, in_progress, done, blocked)
    total = find(:first, :conditions => {id_field => id, :team_id => team_id, :date => Date.today})
    if total
      total.created = created
      total.in_progress = in_progress
      total.done = done
      total.blocked = blocked
      total.save(false)
      total
    else
      create(id_field => id, :team_id => team_id, :date => Date.today, :created => created, :in_progress => in_progress, :done => done, :blocked => blocked) 
    end
  end
  
  # This should be overridden in subclasses.
  def self.id_field
    raise NotImplementedError, "id_field must be implemented by subclass"
  end
  
  # This should be overridden in subclasses.
  def self.find_items(object, team)
    raise NotImplementedError, "find_items must be implemented by subclass"
  end
  
  # This should be overridden in subclasses.
  def self.calculate_effort(item)
    raise NotImplementedError, "calculate_effort must be implemented by subclass"
  end
end