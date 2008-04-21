class StoriesController < ApplicationController
  before_filter :login_required
  before_filter :capture_parent  
  around_filter :update_sort, :only=>[:create, :sort, :row, :update_table]
  
  active_scaffold do |config|
    edit_columns = [:name, :description, :acceptance_criteria, :iteration_id, :individual_id, :effort, :status_code ]
    config.columns = [:name, :iteration_id, :individual_id, :effort, :status_code, :priority ]
    config.columns[:iteration_id].label = 'Iteration' 
    config.columns[:individual_id].label = 'Owner' 
    config.columns[:status_code].label = 'Status' 
    config.create.columns = edit_columns
    config.show.columns = edit_columns
    config.update.columns = edit_columns
    config.list.sorting = {:priority => 'ASC'}
    config.nested.add_link('Tasks', [:tasks])
    config.action_links.add(:split, {:label => 'Split', :type => :record, :crud_type => :update, :inline => true, :position => :after})
    config.list_filter.add(:association, :individual, {:label => 'Owner', :association => [ :individual ] })
    config.list_filter.add(:enumeration, :status, {:label => 'Status', :column => :status_code, :mapping => Story.status_code_mapping })
    config.export.columns = [:name, :description, :acceptance_criteria, :iteration, :individual, :effort, :status ]
    config.columns[:individual].label = 'Owner'
  end

  # Sort the stories (specify the new order by listing the story ids in the desired order).
  # GET /stories/sort
  # GET /stories/sort.xml
  def sort
    respond_to do |format|
      # Stories might have the iteration preceding it (i.e., could be 'stories' or '14-stories')
      story_ids = nil
      params.each_key {|key| if key.to_s.index('stories'); story_ids = params[key]; end}

      # If stories are expanded to show tasks, they can include blank rows which should be ignored.
      story_ids = story_ids.select {|id| id != ''}

      stories = Story.sort(story_ids)
      stories.each { |story| story.save(false) }
      
      format.html { render :partial => 'list_record', :collection => stories, :locals => { :hidden => false } }
      format.xml  { render :xml => stories }
    end
  end

  # Split the story (tasks which have not been accepted will automatically be put in the new story).
  # GET /stories/1/split                Returns a template for the new story.
  # GET /stories/1/split.xml
  # POST /stories/1/split               Creates the new story and moves the unaccepted tasks to it.
  # POST /stories/1/split.xml
  def split
    @old = Story.find(params[:id])
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
      create
      @old.tasks.select{|task| !task.accepted?}.each do |task|
        task.story = @record
        task.save(false)
      end
    end
  end

private

  # When dynamically updating the HTML, Sortable (used for sorting) needs to be re-enabled.
  # This causes it to discover the rows again (including new rows).
  # The workaround is to augment any requesting adding rows with this Javascript.
  # The form varies on whether the response is html or Javascript.
  def update_sort
    respond_to do |format|
      format.html do
        sort = render_to_string :partial => 'sortable', :layout => false
        if request.path_parameters['action'] == 'create'
          # Javascript is expected; Remove the HTML tags
          start = sort.index('CDATA[');
          ending = sort.index('//]');
          sort = ';' + sort.slice(start+6, ending-(start+6))
        end
        yield
        response.body << sort
      end
      format.xml { yield }
    end
  end

  # Keep track of my parent (if I have one).  This is used in my helper methods.
  def capture_parent
    @parent_id = active_scaffold_constraints[:iteration]
    if !@parent_id # sort doesn't have the constraint set, so we have to get it through the key.
      params.each_key {|key| if (index = key.to_s.index('stories')); @parent_id = key.slice(0,index-1); end}
    end
  end
end