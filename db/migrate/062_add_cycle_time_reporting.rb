class AddCycleTimeReporting < ActiveRecord::Migration[4.2]
  def self.up
    add_column :iteration_velocities, :lead_time, :decimal, :precision => 7, :scale => 2
    add_column :iteration_velocities, :cycle_time, :decimal, :precision => 7, :scale => 2
    add_column :iteration_velocities, :num_stories, :integer
    IterationVelocity.reset_column_information # Work around an issue where the new columns are not in the cache.
    IterationVelocity.find_each do |itv|
      itv.num_stories = itv.iteration.num_stories(itv.team)
      itv.lead_time = itv.iteration.lead_time(itv.team)
      itv.cycle_time = itv.iteration.cycle_time(itv.team)
      itv.save( :validate=> false )
    end
  end

  def self.down
    remove_column :iteration_velocities, :lead_time
    remove_column :iteration_velocities, :cycle_time
    remove_column :iteration_velocities, :num_stories
  end
end