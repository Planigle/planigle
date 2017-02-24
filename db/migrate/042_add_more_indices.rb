class AddMoreIndices < ActiveRecord::Migration[4.2]
  def self.up
    add_index :projects, [:company_id], :unique => false
    add_index :teams, [:project_id], :unique => false
    add_index :individuals, [:company_id], :unique => false
    add_index :story_attributes, [:project_id], :unique => false
    add_index :story_attribute_values, [:story_attribute_id], :unique => false
    add_index :criteria, [:story_id], :unique => false
    add_index :story_values, [:story_id], :unique => false
    add_index :individuals_projects, [:project_id], :unique => false
    add_index :individuals_projects, [:individual_id], :unique => false
  end

  def self.down
    remove_index :projects, [:company_id]
    remove_index :teams, [:project_id]
    remove_index :individuals, [:company_id]
    remove_index :story_attributes, [:project_id]
    remove_index :story_attribute_values, [:story_attribute_id]
    remove_index :criteria, [:story_id]
    remove_index :story_values, [:story_id]
    remove_index :individuals_projects, [:project_id]
    remove_index :individuals_projects, [:individual_id]
  end
end