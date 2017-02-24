class AddBlockedToTotals < ActiveRecord::Migration[4.2]
  def self.up
    add_column :iteration_totals, :blocked, :decimal, :precision => 7, :scale => 2
    add_column :release_totals, :blocked, :decimal, :precision => 7, :scale => 2
    Story.with_deleted.each {|story| if story.status_code == 2 then story.status_code(3); story.save( :validate=> false ); end}
    Task.with_deleted.each {|task| if task.status_code == 2 then task.status_code(3); task.save( :validate=> false ); end}
    IterationTotal.update_all :blocked => 0
    ReleaseTotal.update_all :blocked => 0
  end

  def self.down
    remove_column :iteration_totals, :blocked
    remove_column :release_totals, :blocked
    Story.with_deleted.each {|story| if story.status_code == 3 then story.status_code(2); story.save( :validate=> false ); end}
    Task.with_deleted.each {|task| if task.status_code == 3 then task.status_code(2); task.save( :validate=> false ); end}
  end
end
