class SeedUpdateTimes < ActiveRecord::Migration[4.2]
  def self.up
    Company.update_all :updated_at => Time.now
    Project.update_all :updated_at => Time.now
    Team.update_all :updated_at => Time.now
    Individual.update_all :updated_at => Time.now
    Release.update_all :updated_at => Time.now
    Iteration.update_all :updated_at => Time.now
    Story.update_all :updated_at => Time.now
    Task.update_all :updated_at => Time.now
  end

  def self.down
  end
end