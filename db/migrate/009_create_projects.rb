class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects, :force => true do |t|
      t.string :name, :null => false, :limit => 40
      t.text :description, :limit => 4096
    end
    add_column :individuals, :project_id, :integer
    add_column :iterations, :project_id, :integer
    add_column :stories, :project_id, :integer
    default_project = Project.new(:name => 'Default')
    Story.find(:all).each {|story| story.project = default_project; story.save(false)}
    Iteration.find(:all).each {|iteration| iteration.project = default_project; iteration.save(false)}
  end

  def self.down
    drop_table :projects
    remove_column :individuals, :project_id
    remove_column :iterations, :project_id
    remove_column :stories, :project_id
  end
end