class CreateError < ActiveRecord::Migration[4.2]
  def self.up
    create_table( :errors, :force => true ) do |t|
      t.integer :individual_id, :null => false
      t.datetime :time, :null => false
      t.string :message, :null => false, :limit => 256
      t.string :stack_trace, :null => false, :limit => 8192
    end
  end

  def self.down
    drop_table( :errors )
  end
end