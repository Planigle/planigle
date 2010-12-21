class ExtendLicenseAgreement < ActiveRecord::Migration
  def self.up
    change_column :systems, :license_agreement, :text, :default => nil
  end

  def self.down
    change_column :systems, :license_agreement, :string, :default => ''
  end
end
