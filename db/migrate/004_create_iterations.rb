class CreateIterations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :iterations do |t|
      t.string :name
      t.date :start
      t.integer :length, :default => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :iterations
  end
end
