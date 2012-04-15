class IterationVelocity < Total
  belongs_to :iteration
    
  # Create or update summarized data.
  def self.capture(id, team_id, created, in_progress, done, blocked)
    total = find(:first, :conditions => {id_field => id, :team_id => team_id})
    attempted = created + in_progress + done + blocked
    if total
      if !total.attempted || total.attempted == 0
        total.attempted = attempted
      end
      total.completed = done
      total.save(false)
      total
    else
      create(id_field => id, :team_id => team_id, :attempted => attempted, :completed => done) 
    end
  end

  # Allow subclasses to do additional processing
  def self.post_process(iteration, team, total)
    total.lead_time = iteration.average_lead_time(team)
    total.cycle_time = iteration.average_cycle_time(team)
    total.num_stories = iteration.num_stories(team)
    total
  end

  # This should be overridden in subclasses.
  def self.id_field
    :iteration_id
  end
    
  # Answer the items to measure the effort (stories in this case).
  def self.find_items(object, team)
    object.stories.find(:all, :conditions => {:team_id => team ? team.id : nil})
  end
end