class AddRefreshFrequency < ActiveRecord::Migration
  def self.up
    add_column :individuals, :refresh_interval, :integer, :default => 300000
  end

  def self.down
    remove_column :individuals, :refresh_interval
  end
end