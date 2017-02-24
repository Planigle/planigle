class CreateStories < ActiveRecord::Migration[4.2]
  def self.up
    create_table( :stories, :force => true ) do |t|
      t.string :name, :null => false, :limit => 40
      t.text :description, :acceptance_criteria, :limit => 4096
      t.decimal :effort, :precision => 7, :scale => 2
      t.integer :status_code, :null => false, :default => 0
    end
  end

  def self.down
    drop_table( :stories )
  end
end
