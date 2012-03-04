class AddIndividual < ActiveRecord::Migration
  def self.up
    add_column :stories, :individual_id, :integer
  end

  def self.down
    remove_column :stories, :individual_id
  end
end
