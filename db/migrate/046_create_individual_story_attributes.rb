class CreateIndividualStoryAttributes < ActiveRecord::Migration[4.2]
  def self.up
    create_table( :individual_story_attributes, :force => true ) do |t|
      t.integer :individual_id, :null => false
      t.integer :story_attribute_id, :null => false
      t.integer :width, :null => false
      t.decimal :ordering, :precision => 9, :scale => 5
      t.boolean :show, :null => false, :default => false
    end
  end

  def self.down
    drop_table( :individual_story_attributes )
  end
end