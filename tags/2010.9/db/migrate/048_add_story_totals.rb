class AddStoryTotals < ActiveRecord::Migration
  def self.up
    create_table :iteration_story_totals do |t|
      t.integer :iteration_id
      t.date :date
      t.integer :team_id
      t.decimal :created, :precision => 7, :scale => 2
      t.decimal :in_progress, :precision => 7, :scale => 2
      t.decimal :blocked, :precision => 7, :scale => 2
      t.decimal :done, :precision => 7, :scale => 2
    end
  end

  def self.down
    drop_table :iteration_story_totals
  end
end