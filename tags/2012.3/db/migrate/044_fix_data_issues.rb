class FixDataIssues < ActiveRecord::Migration
  def self.up
    Iteration.find_with_deleted(:all, :conditions => ['start < ? and finish > "2008/12/15"', Time.now]).each { |iteration| IterationVelocity.summarize_for(iteration) }
    Task.find_with_deleted(:all, :conditions => 'status_code = 3 and effort > 0').each do |task|
      task.effort = 0
      task.save(false)
    end
  end

  def self.down
  end
end