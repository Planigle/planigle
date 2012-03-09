class IncreaseTaskDescriptionSize < ActiveRecord::Migration
  def self.up
    change_column :tasks, :description, :text, :limit => 20480
  end

  def self.down
    change_column :tasks, :description, :text, :limit => 4096
  end
end