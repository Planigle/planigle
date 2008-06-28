class TasksController < ApplicationController
  before_filter :login_required
  before_filter :capture_parent
  around_filter :update_js, :only=>[:create, :update, :destroy]

  active_scaffold do |config|
    edit_columns = [:name, :description, :individual_id, :effort, :status_code ]
    config.columns = [:name, :individual_id, :effort, :status_code, :story ]
    config.columns[:individual_id].label = 'Owner'
    config.columns[:status_code].label = 'Status'
    config.create.columns = [:name, :description, :individual_id, :effort, :status_code, :story_id ]
    config.show.columns = edit_columns
    config.update.columns = edit_columns
    config.list.sorting = {:status_code => 'DESC', :name => 'ASC'}
    config.list_filter.add(:association, :individual, {:allow_nil => true, :nil_label => 'No Owner', :label => 'Owner', :association => [ :individual ] })
    config.list_filter.add(:enumeration, :status, {:label => 'Status', :column => 'tasks.status_code', :mapping => Task.status_code_mapping })
    config.export.columns = [:name, :description, :individual, :effort, :status ]
    config.columns[:individual].label = 'Owner'
    config.columns[:individual_id].sort_by :sql => '(select min(CONCAT_WS(" ", first_name, last_name)) from individuals where id = tasks.individual_id)'
  end

protected

  # Add in Javascript to cause the containing story to be updated.
  def update_js
    if request.xhr?
      js = render_to_string :partial => 'update_story', :layout => false
    end
    yield
    
    if request.xhr?
      if @parent_id
        # Replace the placeholder with the updated effort
        m = /(.*)(%EFFORT%)(.*)/m.match(js)
        js = m[1] << Story.find(@parent_id).effort.to_s << m[3]
      end

      response.body << js
    end
  end
  
  # Keep track of my parent (if I have one).  This is used in my helper methods.
  def capture_parent
    @parent_id = active_scaffold_constraints[:story_id]
    if @parent_id
      iteration_id = Story.find(@parent_id).iteration_id
      if iteration_id
        @iteration_id = iteration_id.to_s
      end
    end
  end

  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    constraints = super
    constraints[:story_id] = params[:story_id]
    if current_individual.role >= Individual::ProjectAdmin or project_id
      constraints[:story] = {:project => project_id}
    end
    constraints
  end

  # Only project users or higher can create tasks.
  def create_authorized?
    if current_individual.role <= Individual::Admin
      true
    elsif current_individual.role <= Individual::ProjectUser && (!params[:story_id] || project_id == Story.find(params[:story_id]).project_id)
      true
    else
      unauthorized
      false
    end
  end
end
