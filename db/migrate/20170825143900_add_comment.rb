class AddComment < ActiveRecord::Migration[5.0]
  def self.up
    create_table( :comments, :force => true ) do |t|
      t.integer :story_id, :null => false
      t.integer :individual_id, :null => false
      t.integer :ordering, :null => false
      t.datetime :time, :null => false
      t.text :message, :null => false, :limit => 20480
    end
  end
  
  def self.down
    drop_table( :comments )
  end
end
