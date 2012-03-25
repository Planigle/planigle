class CreateAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :story_attribute_values, :force => true do |t|
      t.integer :story_attribute_id
      t.integer :release_id
      t.text :value, :limit => 100
    end
  end

  def self.down
    drop_table :story_attribute_values
  end
end
