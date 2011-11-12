class AddIterationNotable < ActiveRecord::Migration
  def self.up
    add_column :iterations, :notable, :string, :limit => 40
  end

  def self.down
    remove_column :iterations, :notable
  end
end