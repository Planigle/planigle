# Removing to be consistent.

class RemoveTimestamps < ActiveRecord::Migration
  def self.up
    remove_column :iterations, :created_at
    remove_column :iterations, :updated_at
  end

  def self.down
    add_column :iterations, :created_at, :datetime
    add_column :iterations, :updated_at, :datetime
  end
end
