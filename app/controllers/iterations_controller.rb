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

protected

  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    if current_individual.role >= Individual::ProjectAdmin or project_id
      super.merge({:project_id => project_id})
    else
      super
    end
  end
  
  # Only project admins or higher can create iterations.
  def create_authorized?
    if current_individual.role <= Individual::Admin
      true
    elsif current_individual.role <= Individual::ProjectAdmin && (!params[:record] || !params[:record][:project_id] || project_id == params[:record][:project_id])
      true
    else
      unauthorized
      false
    end
  end
end