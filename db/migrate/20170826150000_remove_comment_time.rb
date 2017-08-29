class RemoveCommentTime < ActiveRecord::Migration[5.0]
  def self.up
    remove_column :comments, :time
  end
    
  def self.down
    add_column :comments, :time, :datetime
  end
end
