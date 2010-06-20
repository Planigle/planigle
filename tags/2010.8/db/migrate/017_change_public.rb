class ChangePublic < ActiveRecord::Migration
  def self.up
    rename_column :stories, :public, :is_public
  end

  def self.down
    rename_column :stories, :is_public, :public
  end
end
