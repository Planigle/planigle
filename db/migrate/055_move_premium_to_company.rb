class MovePremiumToCompany < ActiveRecord::Migration[4.2]
  def self.up
    add_column :companies, :premium_expiry, :date
    add_column :companies, :premium_limit, :integer
    add_column :companies, :last_notified_of_expiration, :datetime
    Company.reset_column_information # Work around an issue where the new columns are not in the cache.
    Company.find_each do |company|
      min_val = 10.years.ago
      max_expiry = min_val.to_date
      max_limit = 0
      max_notified = min_val
      company.projects.each do |project|
        if project.premium_expiry > max_expiry
          max_expiry = project.premium_expiry
        end
        if project.premium_limit > max_limit
          max_limit = project.premium_limit
        end
        if project.last_notified_of_expiration != nil && project.last_notified_of_expiration > max_notified
          max_notified = project.last_notified_of_expiration
        end
      end
      if max_notified == min_val
        max_notified = nil
      end
      company.premium_expiry = max_expiry
      company.premium_limit = max_limit
      company.last_notified_of_expiration = max_notified
      company.save( :validate=> false )
    end
    remove_column :projects, :premium_expiry
    remove_column :projects, :premium_limit
    remove_column :projects, :last_notified_of_expiration
end

  def self.down
    add_column :projects, :premium_expiry, :date
    add_column :projects, :premium_limit, :integer
    add_column :projects, :last_notified_of_expiration, :datetime
    Project.reset_column_information # Work around an issue where the new columns are not in the cache.
    Company.find_each do |company|
      company.projects.each do |project|
        project.premium_expiry = company.premium_expiry
        project.premium_limit = company.premium_limit
        project.last_notified_of_expiration = company.last_notified_of_expiration
        project.save( :validate=> false )
      end
    end
    remove_column :companies, :premium_expiry
    remove_column :companies, :premium_limit
    remove_column :companies, :last_notified_of_expiration
  end
end