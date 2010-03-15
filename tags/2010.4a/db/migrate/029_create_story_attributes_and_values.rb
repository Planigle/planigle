class CreateStoryAttributesAndValues < ActiveRecord::Migration
  def self.up
    create_table( :story_attributes, :force => true ) do |t|
      t.integer :project_id, :null => false
      t.string :name, :null => false, :limit => 40
      t.integer :value_type, :null => false
    end
    create_table( :story_values, :force => true ) do |t|
      t.integer :story_id, :null => false
      t.integer :story_attribute_id, :null => false
      t.text :value, :limit => 4096
    end
  end

  def self.down
    drop_table( :story_values )
    drop_table( :story_attributes )
  end
end