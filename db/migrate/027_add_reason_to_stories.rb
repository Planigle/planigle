class AddReasonToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :reason_blocked, :string, :default => "", :limit => 4096
    add_column :tasks, :reason_blocked, :string, :default => "", :limit => 4096
    Story.update_all :reason_blocked => ""
    Task.update_all :reason_blocked => ""
  end

  def self.down
    remove_column :stories, :reason_blocked
    remove_column :tasks, :reason_blocked
  end
end
