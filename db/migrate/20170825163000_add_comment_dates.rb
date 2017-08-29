class AddCommentDates < ActiveRecord::Migration[5.0]
  def self.up
    add_column :comments, :created_at, :datetime
    add_column :comments, :updated_at, :datetime
    add_column :comments, :deleted_at, :datetime
  end
    
  def self.down
    remove_column :comments, :created_at
    remove_column :comments, :updated_at
    remove_column :comments, :deleted_at
  end
end
