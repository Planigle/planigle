class ChangeStoryIndices < ActiveRecord::Migration[4.2]
  def self.up
    remove_index :stories, [:project_id]
    add_index :stories, [:project_id,:status_code], :unique => false
    add_index :stories, [:project_id,:iteration_id], :unique => false
    add_index :stories, [:story_id], :unique => false
  end

  def self.down
    remove_index :stories, [:project_id,:status_code]
    remove_index :stories, [:project_id,:iteration_id]
    remove_index :stories, [:story_id]
    add_index :stories, [:project_id], :unique => false
  end
end