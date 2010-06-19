class AddVelocityToIterations < ActiveRecord::Migration
  def self.up
    create_table :iteration_velocities do |t|
      t.integer :iteration_id
      t.integer :team_id
      t.decimal :attempted, :precision => 7, :scale => 2
      t.decimal :completed, :precision => 7, :scale => 2
    end
    Iteration.find_with_deleted(:all).each do |iteration|
      attempted = nil
      completed = nil
      (Array.new(iteration.project.teams) << nil).each do |team|
        iteration.iteration_totals.find(:all, :conditions => {:team_id => (team ? team.id : nil)}, :order => 'date').each do |total|
          if attempted == nil || attempted == 0 then
            attempted = total.created + total.in_progress + total.blocked + total.done
          end
          completed = total.done
        end
        if attempted != nil || completed != nil
          IterationVelocity.create(:iteration_id => iteration.id, :team_id => (team ? team.id : nil), :attempted => attempted, :completed => completed)
        end
      end
    end
  end

  def self.down
    drop_table :iteration_velocities
  end
end
