class ChangePriority < ActiveRecord::Migration
  def self.up
    change_column :stories, :priority, :decimal, :precision => 9, :scale => 5
  end

  def self.down
    change_column :stories, :priority, :integer
  end
end
