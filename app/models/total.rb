class Total < ActiveRecord::Base
  belongs_to :team

  @abstract_class = true

  # Summarize an object.
  def self.summarize_for(object)
    (Array.new(object.project.teams) << nil).collect do |team|
      created = 0
      in_progress = 0
      done = 0
      (Array.new((team == nil ? Individual.find(:all, :conditions => ['project_id = ? and team_id is null', object.project_id]) : team.individuals)) << nil).each do |individual|
        object.stories.each do |story|
          effort = story.calculated_effort_for(team, individual)
          effort = effort != nil ? effort : 0
          case story.status_code
            when Story::Created then created += effort
            when Story::InProgress then in_progress += effort
            else done += effort
          end
        end
      end
      capture( object.id, team ? team.id : nil, created, in_progress, done)
    end
  end
  
  # Create or update summarized data.
  def self.capture(id, team_id, created, in_progress, done)
    total = find(:first, :conditions => {id_field => id, :team_id => team_id, :date => Time.today})
    if total
      total.created = created
      total.in_progress = in_progress
      total.done = done
      total.save(false)
    else
      create(id_field => id, :team_id => team_id, :date => Time.today, :created => created, :in_progress => in_progress, :done => done) 
    end
  end
  
  # This should be overridden in subclasses.
  def self.id_field
    raise NotImplementedError, "id_field must be implemented by subclass"
  end
end