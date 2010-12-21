class AddSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys, :force => true do |t|
      t.integer :project_id, :null => false
      t.string :email, :null => false, :limit => 100
      t.boolean :excluded, :default => false
      t.timestamps
    end
    create_table :survey_mappings, :force => true do |t|
      t.integer :survey_id, :null => false
      t.integer :story_id
      t.integer :priority
    end
    add_column :projects, :survey_key, :string, :limit => 40, :null => false
    add_column :projects, :survey_mode, :integer, :null => false
    Project.find_with_deleted(:all).each do |project|
      project.initialize_defaults
      project.survey_mode = 0
      project.save(false)
    end
    add_column :stories, :public, :boolean, :default => false
    add_column :stories, :user_priority, :decimal, :precision => 7, :scale => 3
    Story.find_with_deleted(:all).each do |story|
      story.public = false
      story.save(false)
    end
  end

  def self.down
    remove_column :stories, :user_priority
    remove_column :stories, :public
    remove_column :projects, :survey_mode
    remove_column :projects, :survey_key
    
    drop_table :survey_mappings
    drop_table :surveys
  end
end
