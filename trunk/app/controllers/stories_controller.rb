class StoriesController < ApplicationController
  before_filter :login_required
  
  active_scaffold do |config|
    edit_columns = [:project_id, :name, :description, :acceptance_criteria, :iteration_id, :individual_id, :effort, :status_code, :priority, :public ]
    config.columns = [:project_id, :name, :iteration_id, :individual_id, :effort, :status_code, :priority, :public ]
    config.columns[:project_id].label = 'Project' 
    config.columns[:iteration_id].label = 'Iteration' 
    config.columns[:individual_id].label = 'Owner' 
    config.columns[:status_code].label = 'Status' 
    config.create.columns = edit_columns
    config.show.columns = edit_columns
    config.update.columns = edit_columns
    config.list.sorting = {:priority => 'ASC'}
    config.nested.add_link('Tasks', [:tasks])
    config.action_links.add(:split, {:label => 'Split', :type => :record, :crud_type => :update, :inline => true, :position => :after})
    config.list_filter.add(:association, :individual, {:allow_nil => true, :nil_label => 'No Owner', :label => 'Owner', :association => [ :individual ] })
    config.list_filter.add(:enumeration, :status, {:label => 'Status', :column => :status_code, :mapping => Story.status_code_mapping })
    config.export.columns = [:project, :name, :description, :acceptance_criteria, :iteration, :individual, :effort, :status ]
    config.columns[:individual].label = 'Owner'
    config.columns[:project_id].sort_by :sql => '(select min(name) from projects where id = project_id)'
    config.columns[:iteration_id].sort_by :sql => '(select min(start) from iterations where id = iteration_id)'
    config.columns[:individual_id].sort_by :sql => '(select min(CONCAT_WS(" ", first_name, last_name)) from individuals where id = individual_id)'
    config.columns[:effort].sort_by :sql => '(if(effort IS NULL, (select sum(tasks.effort) from tasks where story_id = stories.id), effort))'
  end

  # Split the story (tasks which have not been accepted will automatically be put in the new story).
  # GET /stories/1/split                Returns a template for the new story.
  # GET /stories/1/split.xml
  # POST /stories/1/split               Creates the new story and moves the unaccepted tasks to it.
  # POST /stories/1/split.xml
  def split
    @old = Story.find(params[:id])
    
    # Needed for authorization check
    if !params[:record]; params[:record] = {}; end
    if !params[:record][:project_id]; params[:record][:project_id] = @old.project_id; end

    if create_authorized?
      if request.get?
        @record = @old.split
        respond_to do |format|
          format.html {render :action => 'split', :layout => false}
          format.xml {render :xml => @record }
        end
      else
        iteration_id = params[:record][:iteration_id]
        if @parent_id && iteration_id && iteration_id != ''  # If already constrained, adapt the contraint
          @parent_id = iteration_id.to_s
        end
        active_scaffold_constraints[:iteration] = @parent_id
        params[:tasks] = @old.tasks.select{|task| !task.accepted?}
        create
      end
    end
  end

protected

  # Automatically include tasks (to reduce number of queries).
  def active_scaffold_joins
    super.concat [:tasks]
  end

  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    constraints = super
    if constraints.include?(:iteration)
      constraints[:iteration_id] = constraints[:iteration] # Add id form so that column is hidden.
      constraints.merge({:project_id => Iteration.find(constraints[:iteration]).project_id})
    elsif current_individual.role >= Individual::ProjectAdmin or project_id
      constraints.merge({:project_id => project_id})
    else
      constraints
    end
  end
  
  # Override create to allow automatic association of tasks (set in split).
  def after_create_save(story)
    if params[:tasks]
      params[:tasks].each do |task|
        story.tasks << task
        task.save
      end
    end
  end
  
  # Update the surveys if the story is unaccepted.
  def do_update
    @record = find_if_allowed(params[:id], :update)
    should_update = (params["record"]["status_code"] !=2 and @record.status_code == 2)
    Story.transaction do
      result = super
      if should_update
        Survey.update_rankings(@record.project).each do |story|
          story.save(false)
        end
      end
      result
    end
  end
  
  # Only project users or higher can create stories.
  def create_authorized?
    if current_individual.role <= Individual::Admin
      true
    elsif current_individual.role <= Individual::ProjectUser && (!params[:record] || !params[:record][:project_id] || project_id == params[:record][:project_id].to_i)
      true
    else
      unauthorized
      false
    end
  end
end