class CreateEpics < ActiveRecord::Migration
  def self.up
    add_column :stories, :story_id, :integer
  end

  def self.down
    remove_column :stories, :story_id
  end
end
