class ProjectsController < ApplicationController
  before_filter :login_required
  active_scaffold do |config|
    config.columns = [:name, :description]
    config.list.sorting = {:name => 'ASC'}
  end

protected
  
  # If the user is assigned to a project, they can't create new ones.
  def create_authorized?
    !project_id
  end
  
  # If the user is assigned to a project, they can't delete it.
  def delete_authorized?
    !project_id
  end
  
  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    if current_individual.project
      super.merge({:id => project_id})
    else
      super
    end
  end
end
