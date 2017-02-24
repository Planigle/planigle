class RemoveLengthDefault < ActiveRecord::Migration[4.2]
  def self.up
    change_column_default :iterations, :length, nil
  end

  def self.down
    change_column_default :iterations, :length, 2
  end
end