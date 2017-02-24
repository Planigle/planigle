class CreateCompanies < ActiveRecord::Migration[4.2]
  def self.up
    create_table :companies, :force => true do |t|
      t.string :name, :null => false, :limit => 40
    end
    add_column :projects, :company_id, :integer
    add_column :individuals, :company_id, :integer

    Project.reset_column_information # Work around an issue where the new columns are not in the cache.
    Individual.reset_column_information # Work around an issue where the new columns are not in the cache.
    Project.with_deleted.each do |project|
      company = Company.create(:name => project.name)
      project.company = company
      project.save( :validate=> false )
      project.individuals.each {|individual| individual.company = company; individual.save( :validate=> false )}
    end
  end

  def self.down
    remove_column :individuals, :company_id
    remove_column :projects, :company_id
    drop_table :companies
  end
end
