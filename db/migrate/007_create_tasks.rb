class CreateTasks < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tasks do |t|
      t.string :name, :null => false, :limit => 40
      t.text :description, :limit => 4096
      t.decimal :effort, :precision => 7, :scale => 2
      t.integer :status_code, :null => false, :default => 0
      t.integer :individual_id
      t.integer :story_id
    end
  end

  def self.down
    drop_table :tasks
  end
end
