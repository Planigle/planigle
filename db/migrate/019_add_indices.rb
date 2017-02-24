class AddIndices < ActiveRecord::Migration[4.2]
  def self.up
    add_index :individuals, [:project_id], :unique => false
    add_index :individuals, [:remember_token], :unique => false
    add_index :releases, [:project_id], :unique => false
    add_index :iterations, [:project_id], :unique => false
    add_index :stories, [:project_id], :unique => false
    add_index :tasks, [:story_id], :unique => false
    add_index :projects, [:survey_key], :unique => true
    add_index :surveys, [:project_id], :unique => false
    add_index :survey_mappings, [:survey_id], :unique => false
  end

  def self.down
    remove_index :individuals, [:project_id]
    remove_index :individuals, [:remember_token]
    remove_index :releases, [:project_id]
    remove_index :iterations, [:project_id]
    remove_index :stories, [:project_id]
    remove_index :tasks, [:story_id]
    remove_index :projects, [:survey_key]
    remove_index :surveys, [:project_id]
    remove_index :survey_mappings, [:survey_id]
  end
end