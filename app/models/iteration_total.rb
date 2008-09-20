class IterationTotal < ActiveRecord::Base
  belongs_to :iteration
  belongs_to :team
  
  # Create or update summarized data.
  def self.capture(iteration_id, team_id, created, in_progress, done)
    total = IterationTotal.find(:first, :conditions => {:iteration_id => iteration_id, :team_id => team_id, :date => Time.today})
    if total
      total.created = created
      total.in_progress = in_progress
      total.done = done
      total.save(false)
    else
      IterationTotal.create(:iteration_id => iteration_id, :team_id => team_id, :date => Time.today, :created => created, :in_progress => in_progress, :done => done) 
    end
  end
end