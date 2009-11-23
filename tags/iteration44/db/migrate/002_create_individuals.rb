class CreateIndividuals < ActiveRecord::Migration
  DefaultLogin = 'admin'
  DefaultPassword = 'admin'
  
  def self.up
    create_table "individuals", :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :email,                     :string, :limit => 100
      t.column :first_name,                :string, :limit => 40
      t.column :last_name,                 :string, :limit => 40
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :enabled, :boolean, :default => true
      end

    "Create the default user"
    individual = Individual.new
    individual.login = DefaultLogin
    individual.email = 'foo@bar.com'
    individual.first_name = DefaultLogin
    individual.last_name = DefaultLogin
    individual.password = DefaultPassword
    individual.password_confirmation = DefaultPassword
    individual.activate!
    individual.save( false )
  end

  def self.down
    drop_table "individuals"
  end
end
