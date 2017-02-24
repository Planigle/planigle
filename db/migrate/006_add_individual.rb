class AddIndividual < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :individual_id, :integer
  end

  def self.down
    remove_column :stories, :individual_id
  end
end
