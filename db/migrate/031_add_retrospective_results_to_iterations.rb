class AddRetrospectiveResultsToIterations < ActiveRecord::Migration[4.2]
  def self.up
    add_column :iterations, :retrospective_results, :text, :limit => 4096
    Iteration.with_deleted.each {|iteration| iteration.retrospective_results(""); iteration.save( :validate=> false );}
  end

  def self.down
    remove_column :iterations, :retrospective_results
  end
end
