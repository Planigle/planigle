class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.integer :project_id
      t.string :name
      t.date :start
      t.date :finish
    end
    add_column :stories, :release_id, :integer
    Project.find_with_deleted(:all).each do |project|
      iterations = project.iterations(:order => "start")
      if !iterations.empty?
        id = Release.create(:name =>"Current Release", :project_id => project.id, :start => iterations.first.start, :finish => iterations.last.start + iterations.last.length * 7).id
        Story.update_all({:release_id => id}, ["project_id = ? and iteration_id is not null", project.id])
      end
    end
  end

  def self.down
    remove_column :stories, :release_id
    drop_table :releases
  end
end
