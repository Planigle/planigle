class AddBlockedToTotals < ActiveRecord::Migration
  def self.up
    add_column :iteration_totals, :blocked, :decimal, :precision => 7, :scale => 2
    add_column :release_totals, :blocked, :decimal, :precision => 7, :scale => 2
    Story.update_all({:status_code => 3}, {:status_code => 2})
    Task.update_all({:status_code => 3}, {:status_code => 2})
    IterationTotal.update_all :blocked => 0
    ReleaseTotal.update_all :blocked => 0
  end

  def self.down
    remove_column :iteration_totals, :blocked
    remove_column :release_totals, :blocked
    Story.update_all({:status_code => 2}, {:status_code => 3})
    Task.update_all({:status_code => 2}, {:status_code => 3})
  end
end
