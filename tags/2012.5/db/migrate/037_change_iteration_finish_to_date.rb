class ChangeIterationFinishToDate < ActiveRecord::Migration
  def self.up
    add_column :iterations, :finish, :date, :null => false
    Iteration.reset_column_information # Work around an issue where the new columns are not in the cache.
    Iteration.find_with_deleted(:all).each do |iteration|
      iteration.finish = iteration.start + iteration.length * 7
      iteration.save(false)
    end
    remove_column :iterations, :length
  end

  def self.down
    add_column :iterations, :length, :integer, :default => 2
    Iteration.reset_column_information # Work around an issue where the new columns are not in the cache.
    Iteration.find_with_deleted(:all).each do |iteration|
      iteration.length = (iteration.start - iteration.finish) / 7
      iteration.save(false)
    end
    remove_column :iterations, :finish
  end
end
