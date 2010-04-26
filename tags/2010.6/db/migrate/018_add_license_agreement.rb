class AddLicenseAgreement < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
      t.string :license_agreement, :default => ''
    end
    add_column :individuals, :last_login, :datetime
    add_column :individuals, :accepted_agreement, :datetime
    System.create(:license_agreement => '')
  end

  def self.down
    remove_column :individuals, :accepted_agreement
    remove_column :individuals, :last_login
    drop_table :systems
  end
end
