class ProjectsController < ApplicationController
  before_filter :login_required
  active_scaffold do |config|
    config.columns = [:name, :description, :survey_mode]
    config.list.sorting = {:name => 'ASC'}
  end

protected

  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    if current_individual.role >= Individual::ProjectAdmin
      super.merge({:id => project_id})
    else
      super
    end
  end
  
  # Only admins can create projects.
  def create_authorized?
    if current_individual.role <= Individual::Admin
      true
    else
      unauthorized
      false
    end
  end
end
