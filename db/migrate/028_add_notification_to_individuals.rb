class AddNotificationToIndividuals < ActiveRecord::Migration[4.2]
  def self.up
    add_column :individuals, :phone_number, :string, :limit => 20
    add_column :individuals, :notification_type, :integer, :default => 0
  end

  def self.down
    remove_column :individuals, :phone_number
    remove_column :individuals, :notification_type
  end
end
