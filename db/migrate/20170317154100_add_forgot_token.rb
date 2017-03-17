class AddForgotToken < ActiveRecord::Migration[5.0]
  def self.up
    add_column :individuals, :forgot_token, :string
    add_column :individuals, :forgot_token_expires_at, :datetime
  end

  def self.down
    remove_column :individuals, forgot_token_expires_at
    remove_column :individuals, :forgot_token
  end
end
