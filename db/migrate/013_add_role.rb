class AddRole < ActiveRecord::Migration[4.2]
  def self.up
    add_column :individuals, :role, :integer
    Individual.reset_column_information # Work around an issue where the new columns are not in the cache.
    $auditing_disabled = true
    Individual.with_deleted.each {|individual| individual.role = individual.read_attribute(:project_id) == nil ? 0 : 1; individual.save( :validate=> false )}
    $auditing_disabled = nil
  end

  def self.down
    remove_column :individuals, :role
  end
end
