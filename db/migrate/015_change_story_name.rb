class ChangeStoryName < ActiveRecord::Migration[4.2]
  def self.up
    change_column :stories, :name, :string, :null => false, :limit => 250
  end

  def self.down
    change_column :stories, :name, :string, :null => false, :limit => 40
  end
end
