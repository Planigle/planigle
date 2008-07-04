class ChangeStoryName < ActiveRecord::Migration
  def self.up
    change_column :stories, :name, :string, :null => false, :limit => 250
  end

  def self.down
    change_column :stories, :name, :string, :null => false, :limit => 40
  end
end
