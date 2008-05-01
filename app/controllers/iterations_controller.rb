class IterationsController < ApplicationController
  before_filter :login_required
  active_scaffold do |config|
    config.columns = [:project_id, :name, :start, :length ]
    config.columns[:project_id].label = 'Project' 
    config.columns[:length].label = 'Length (in weeks)' 
    config.list.sorting = {:start => 'ASC'}
    config.nested.add_link('Stories', [:stories])
    config.export.columns = [:project, :name, :start, :length ]
    config.columns[:project_id].sort_by :sql => '(select min(name) from projects where id = project_id)'
  end

private
  
  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    if current_individual.project
      super.merge({:project_id => project_id})
    else
      super
    end
  end
end