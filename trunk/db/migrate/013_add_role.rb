class AddRole < ActiveRecord::Migration
  def self.up
    add_column :individuals, :role, :integer
    Individual.reset_column_information # Work around an issue where the new columns are not in the cache.
    Individual.find_with_deleted(:all).each {|individual| individual.role = individual.read_attribute(:project_id) == nil ? 0 : 1; individual.save(false)}
  end

  def self.down
    remove_column :individuals, :role
  end
end
