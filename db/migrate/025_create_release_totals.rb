class CreateReleaseTotals < ActiveRecord::Migration[4.2]
  def self.up
    create_table :release_totals do |t|
      t.integer :release_id
      t.integer :team_id
      t.date :date
      t.decimal :created, :precision => 7, :scale => 2
      t.decimal :in_progress, :precision => 7, :scale => 2
      t.decimal :done, :precision => 7, :scale => 2
    end
  end

  def self.down
    drop_table :release_totals
  end
end
