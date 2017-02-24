class CreateCriteria < ActiveRecord::Migration[4.2]
  def self.up
    create_table :criteria do |t|
      t.text :description, :null => false, :limit => 4096
      t.integer :status_code, :null => false, :default => 0
      t.integer :story_id
      t.decimal :priority, :precision => 9, :scale => 5
    end
    Story.with_deleted.each do |story|
      story.acceptance_criteria = story['acceptance_criteria']
    end
    remove_column :stories, :acceptance_criteria
  end

  def self.down
    add_column :stories, :acceptance_criteria, :text, :limit => 4096
    Story.reset_column_information # Work around an issue where the new columns are not in the cache.
    Story.with_deleted.each do |story|
      story['acceptance_criteria'] = story.acceptance_criteria[0,4096]
    end
    drop_table :criteria
  end
end
