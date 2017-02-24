class FixDataIssues < ActiveRecord::Migration[4.2]
  def self.up
    Iteration.with_deleted.each do |iteration|
      if start < Time.now and finish > Time.new(2008, 12, 15)
        IterationVelocity.summarize_for(iteration)
      end
    end
    Task.with_deleted.each do |task|
      if task.status_code == 3 && effort > 0
        task.effort = 0
        task.save( :validate=> false )
      end
    end
  end

  def self.down
  end
end