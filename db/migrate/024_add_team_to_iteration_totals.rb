class AddTeamToIterationTotals < ActiveRecord::Migration[4.2]
  def self.up
    add_column :iteration_totals, :team_id, :integer
  end

  def self.down
    remove_column :iteration_totals, :team_id
  end
end
