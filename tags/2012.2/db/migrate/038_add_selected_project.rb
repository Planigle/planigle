class AddSelectedProject < ActiveRecord::Migration
  def self.up
    add_column :individuals, :selected_project_id, :integer
  end

  def self.down
    remove_column :individuals, :selected_project_id
  end
end
