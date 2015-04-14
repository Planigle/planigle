class AddReasonToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :reason_blocked, :text, :limit => 4096
    add_column :tasks, :reason_blocked, :text, :limit => 4096
    Story.with_deleted.each {|story| story.reason_blocked(""); story.save( :validate=> false )}
    Task.with_deleted.each {|story| story.reason_blocked(""); story.save( :validate=> false )}
  end

  def self.down
    remove_column :stories, :reason_blocked
    remove_column :tasks, :reason_blocked
  end
end
