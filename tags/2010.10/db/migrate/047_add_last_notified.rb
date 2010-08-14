class AddLastNotified < ActiveRecord::Migration
  def self.up
    add_column :projects, :last_notified_of_inactivity, :datetime
    add_column :projects, :last_notified_of_expiration, :datetime
  end

  def self.down
    remove_column :projects, :last_notified_of_expiration
    remove_column :projects, :last_notified_of_inactivity
  end
end