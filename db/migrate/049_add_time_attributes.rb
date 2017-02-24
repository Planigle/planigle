class AddTimeAttributes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :companies, :created_at, :datetime
    add_column :companies, :updated_at, :datetime
    add_column :companies, :deleted_at, :datetime

    add_column :projects, :created_at, :datetime
    add_column :projects, :updated_at, :datetime
    add_column :projects, :deleted_at, :datetime

    add_column :teams, :created_at, :datetime
    add_column :teams, :updated_at, :datetime
    add_column :teams, :deleted_at, :datetime

    add_column :individuals, :created_at, :datetime
    add_column :individuals, :updated_at, :datetime
    add_column :individuals, :deleted_at, :datetime

    add_column :releases, :created_at, :datetime
    add_column :releases, :updated_at, :datetime
    add_column :releases, :deleted_at, :datetime

    add_column :iterations, :created_at, :datetime
    add_column :iterations, :updated_at, :datetime
    add_column :iterations, :deleted_at, :datetime

    add_column :stories, :created_at, :datetime
    add_column :stories, :updated_at, :datetime
    add_column :stories, :deleted_at, :datetime

    add_column :tasks, :created_at, :datetime
    add_column :tasks, :updated_at, :datetime
    add_column :tasks, :deleted_at, :datetime
  end

  def self.down
    remove_column :companies, :created_at
    remove_column :companies, :updated_at
    remove_column :companies, :deleted_at

    remove_column :projects, :created_at
    remove_column :projects, :updated_at
    remove_column :projects, :deleted_at

    remove_column :teams, :created_at
    remove_column :teams, :updated_at
    remove_column :teams, :deleted_at

    remove_column :individuals, :created_at
    remove_column :individuals, :updated_at
    remove_column :individuals, :deleted_at

    remove_column :releases, :created_at
    remove_column :releases, :updated_at
    remove_column :releases, :deleted_at

    remove_column :iterations, :created_at
    remove_column :iterations, :updated_at
    remove_column :iterations, :deleted_at

    remove_column :stories, :created_at
    remove_column :stories, :updated_at
    remove_column :stories, :deleted_at

    remove_column :tasks, :created_at
    remove_column :tasks, :updated_at
    remove_column :tasks, :deleted_at
  end
end