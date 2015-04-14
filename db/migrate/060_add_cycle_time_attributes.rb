class AddCycleTimeAttributes < ActiveRecord::Migration
  def self.up
    add_column :stories, :in_progress_at, :datetime
    add_column :stories, :done_at, :datetime
    Story.reset_column_information # Work around an issue where the new columns are not in the cache.
    Story.with_deleted.each do |story|
      if story.status_code.to_i >= Story.InProgress
        current_value = 0
        new_value = 0
        story.audits.find(:all, :order => 'created_at').each do |audit|
          if(audit.changes['status_code'])
            new_value = audit.changes['status_code'][1].to_i
          end
          if current_value == 0 && new_value != 0
            story.in_progress_at = audit.created_at
          end
          if story.status_code.to_i == Story.Done && current_value != new_value && new_value == Story.Done
            story.done_at = audit.created_at
          end
          current_value = new_value
        end
      end
      story.save( :validate=> false )
    end
    add_column :tasks, :in_progress_at, :datetime
    add_column :tasks, :done_at, :datetime
    Task.reset_column_information # Work around an issue where the new columns are not in the cache.
    Task.with_deleted.each do |task|
      if task.status_code.to_i >= Story.InProgress
        current_value = 0
        new_value = 0
        task.audits.find(:all, :order => 'created_at').each do |audit|
          if(audit.changes['status_code'])
            new_value = audit.changes['status_code'][1].to_i
          end
          if current_value == 0 && new_value != 0
            task.in_progress_at = audit.created_at
          end
          if task.status_code.to_i == Story.Done && current_value != new_value && new_value == Story.Done
            task.done_at = audit.created_at
          end
          current_value = new_value
        end
      end
      task.save( :validate=> false )
    end
  end

  def self.down
    remove_column :stories, :in_progress_at
    remove_column :stories, :done_at
    remove_column :tasks, :in_progress_at
    remove_column :tasks, :done_at
  end
end