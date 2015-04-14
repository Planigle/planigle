class CreateIndividuals < ActiveRecord::Migration
  DefaultLogin = 'admin'
  DefaultPassword = 'admin'
  
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :auditable_name, :string
      t.column :project_id, :integer
      t.column :user_id, :integer
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audited_changes, :text
      t.column :comment, :text
      t.column :version, :integer, :default => 0
      t.column :request_uuid, :string
      t.column :remote_address, :string
      t.column :created_at, :datetime
    end
    
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:project_id], :name => 'project_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at  

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

    # Create the default user
    individual = Individual.new
    individual.login = DefaultLogin
    individual.email = 'foo@bar.com'
    individual.first_name = DefaultLogin
    individual.last_name = DefaultLogin
    individual.password = DefaultPassword
    individual.password_confirmation = DefaultPassword
    individual.activate!
    individual.save( :validate=> false )
  end

  def self.down
    drop_table :audits
    drop_table "individuals"
  end
end
