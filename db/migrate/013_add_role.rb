class AddRole < ActiveRecord::Migration
  def self.up
    add_column :individuals, :role, :integer
    Individual.find(:all).each {|individual| individual.role = individual.project_id == nil ? 0 : 1; individual.save(false)}
  end

  def self.down
    remove_column :individuals, :role
  end
end
