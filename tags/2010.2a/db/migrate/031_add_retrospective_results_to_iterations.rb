class AddRetrospectiveResultsToIterations < ActiveRecord::Migration
  def self.up
    add_column :iterations, :retrospective_results, :text, :limit => 4096
    Iteration.update_all :retrospective_results => ""
  end

  def self.down
    remove_column :iterations, :retrospective_results
  end
end
