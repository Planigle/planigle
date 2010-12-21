class ChangeTaskNameLength < ActiveRecord::Migration
  def self.up
    change_column :tasks, :name, :string, :null => false, :limit => 250
  end

  def self.down
    change_column :tasks, :name, :string, :null => false, :limit => 40
  end
end
