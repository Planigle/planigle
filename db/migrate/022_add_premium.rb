class AddPremium < ActiveRecord::Migration[4.2]
  def self.up
    add_column :projects, :premium_expiry, :date
    add_column :projects, :premium_limit, :integer
    Project.with_deleted.each {|project| project.premium_expiry(Date.yesterday); project.premium_limit(1000); project.save( :validate=> false )}
  end

  def self.down
    remove_column :projects, :premium_expiry
    remove_column :projects, :premium_limit
  end
end
