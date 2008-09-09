class AddPremium < ActiveRecord::Migration
  def self.up
    add_column :projects, :premium_expiry, :datetime
    add_column :projects, :premium_limit, :integer
    Project.update_all :premium_expiry => Time.now + 30*24*60*60, :premium_limit => 1000
  end

  def self.down
    remove_column :projects, :premium_expiry
    remove_column :projects, :premium_limit
  end
end
