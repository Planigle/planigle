class ManyProjectsPerIndividual < ActiveRecord::Migration
  def self.up
    create_table :individuals_projects, :id => false do |t|
      t.integer :project_id
      t.integer :individual_id
    end
    Individual.find_with_deleted(:all).each do |individual|
      project_id = individual.read_attribute(:project_id)
      if project_id
        individual.projects << Project.find(project_id)
        individual.save(false)
      end
    end
    remove_column :individuals, :project_id
  end

  def self.down
    add_column :individuals, :project_id, :integer
    Individual.reset_column_information # Work around an issue where the new columns are not in the cache.
    Individual.find_with_deleted(:all).each do |individual|
      if (!individual.projects.empty?)
        individual.write_attribute(:project_id, individual.projects[0].id)
        individual.save(false)
      end
    end
    drop_table :individuals_projects
    add_index :individuals, [:project_id], :unique => false
  end
end
