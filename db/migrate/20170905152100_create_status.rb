class CreateStatus < ActiveRecord::Migration[5.0]
  def self.up
    create_table :statuses do |t|
      t.integer  :project_id,           null: false
      t.string   :name,                 null: false
      t.integer  :status_code,          null: false
      t.boolean  :applies_to_stories,   null: false
      t.boolean  :applies_to_tasks,     null: false
      t.integer  :ordering,             null: false
      t.datetime :created_at,           null: true
      t.datetime :updated_at,           null: true
      t.datetime :deleted_at,           null: true
    end

    add_index :statuses, :project_id, unique: false

    add_column :stories, :status_id, :integer, null: false
    add_column :tasks, :status_id, :integer, null: false
    
    execute "INSERT INTO statuses (project_id, name, status_code, applies_to_stories, applies_to_tasks, ordering, created_at) SELECT id, 'Not Started', 0, 1, 1, 1, CURRENT_TIMESTAMP FROM projects"
    execute "INSERT INTO statuses (project_id, name, status_code, applies_to_stories, applies_to_tasks, ordering, created_at) SELECT id, 'In Progress', 1, 1, 1, 2, CURRENT_TIMESTAMP FROM projects"
    execute "INSERT INTO statuses (project_id, name, status_code, applies_to_stories, applies_to_tasks, ordering, created_at) SELECT id, 'Blocked', 2, 1, 1, 3, CURRENT_TIMESTAMP FROM projects"
    execute "INSERT INTO statuses (project_id, name, status_code, applies_to_stories, applies_to_tasks, ordering, created_at) SELECT id, 'Done', 3, 1, 1, 4, CURRENT_TIMESTAMP FROM projects"
    execute "UPDATE stories, statuses SET stories.status_id=statuses.id WHERE stories.project_id=statuses.project_id AND stories.status_code=statuses.status_code"
    execute "UPDATE tasks, stories, statuses SET tasks.status_id=statuses.id WHERE tasks.story_id=stories.id AND stories.project_id=statuses.project_id AND tasks.status_code=statuses.status_code"
    
    remove_column :stories, :status_code
    remove_column :tasks, :status_code
  end

  def self.down
    add_column :stories, :status_code, :integer, null: false
    add_column :tasks, :status_code, :integer, null: false
    execute "UPDATE stories, statuses SET stories.status_code=statuses.status_code WHERE stories.status_id=statuses.id"
    execute "UPDATE tasks, statuses SET tasks.status_code=statuses.status_code WHERE tasks.status_id=statuses.id"
    remove_column :stories, :status_id
    remove_column :tasks, :status_id
    drop_table :statuses
  end
end
