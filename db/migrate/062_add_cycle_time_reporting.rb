class AddCycleTimeReporting < ActiveRecord::Migration
  def self.up
    add_column :iteration_velocities, :lead_time, :decimal, :precision => 7, :scale => 2
    add_column :iteration_velocities, :cycle_time, :decimal, :precision => 7, :scale => 2
    IterationVelocity.reset_column_information # Work around an issue where the new columns are not in the cache.
    IterationVelocity.find(:all).each do |itv|
      itv.lead_time = itv.iteration.average_lead_time
      itv.cycle_time = itv.iteration.average_cycle_time
      itv.save(false)
    end
  end

  def self.down
    remove_column :iteration_velocities, :lead_time
    remove_column :iteration_velocities, :cycle_time
  end
end