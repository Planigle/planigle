class AddTaskPriority < ActiveRecord::Migration
  def self.up
    add_column :tasks, :priority, :decimal, :precision => 9, :scale => 5
    Task.reset_column_information # Work around an issue where the new columns are not in the cache.
    Story.with_deleted.each do |story|
      priority = 1
      story.tasks.find(:all, :order => 'status_code desc, name').each do |task|
        task.priority = priority;
        task.save( :validate=> false );
        priority += 1;
      end
    end
  end

  def self.down
    remove_column :tasks, :priority
  end
end
