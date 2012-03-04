class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name, :null => false, :limit => 40
      t.text :description, :limit => 4096
      t.integer :project_id
    end
    add_column :individuals, :team_id, :integer
    add_column :stories, :team_id, :integer
  end

  def self.down
    remove_column :stories, :team_id
    remove_column :individuals, :team_id
    drop_table :teams
  end
end
