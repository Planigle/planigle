class StoriesController < ApplicationController
  before_filter :login_required
  before_filter :capture_parent  
  around_filter :update_sort, :only=>[:create, :sort_stories, :row, :update_table]
  
  active_scaffold do |config|
    config.columns = [:name, :iteration_id, :individual_id, :effort, :status_code, :priority ]
    config.columns[:iteration_id].label = 'Iteration' 
    config.columns[:individual_id].label = 'Owner' 
    config.columns[:status_code].label = 'Status' 
    config.create.columns = [:name, :description, :acceptance_criteria, :iteration_id, :individual_id, :effort, :status_code ]
    config.show.columns = [:name, :description, :acceptance_criteria, :iteration_id, :individual_id, :effort, :status_code ]
    config.update.columns = [:name, :description, :acceptance_criteria, :iteration_id, :individual_id, :effort, :status_code ]
    config.list.sorting = {:priority => 'ASC'}
    config.nested.add_link('Tasks', [:tasks])
  end

  # Sort the stories (specify the new order by listing the story ids in the desired order).
  # GET /stories/sort_stories
  # GET /stories/sort_stories.xml
  def sort_stories
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
    if !@parent_id # sort_stories doesn't have the constraint set, so we have to get it through the key.
      params.each_key {|key| if (index = key.to_s.index('stories')); @parent_id = key.slice(0,index-1); end}
    end
    if !@parent_id # Last ditch, use the id key if it exists.
      id = params[:id]
      if id
        @parent_id = Story.find(id).iteration_id.to_s
      end
    end
  end
end