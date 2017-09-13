class AddCommentIndex < ActiveRecord::Migration[5.0]
  def self.up
    add_index :comments, :story_id, unique: false
  end
    
  def self.down
    remove_index :comments, :story_id
  end
end
