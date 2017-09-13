class StoriesController < ResourceController
  before_action only: [:index, :show, :export, :num_pages, :epics] do
    log_in_or_oauth :read
  end
  before_action only: [:create, :update, :destroy, :import, :split] do
    log_in_or_oauth :backlog
  end

  STORIES_PER_PAGE = 100

  # GET /stories
  def index
    @records = get_records
    render :json => @records
  end
  
  # POST /stories/import               Imports new/existing stories.
  def import
    errors = nil
    Story.transaction do
      errors = Story.import(current_individual, (params['Filedata'].is_a?(String) ? params['Filedata'] : params['Filedata'].read))
      if errors.detect {|error| !error.empty?}
        raise "Errors importing data"
      end
      render :json => {result: "Data was successfully imported"}
    end
  rescue Exception => e
    result = {}
    if errors
      errorStrings = []
      row = 2 # includes header row
      errors.each do |error|
        if error.full_messages.length>0
          error.full_messages.each {|message| errorStrings << ('Row ' + row.to_s + ': ' + message)}
        end
        row += 1
      end
      result[:error] = errorStrings.join("<br>")
    else
      result[:error] = "File format is invalid (must be CSV / comma separated values)"
    end
    render :json => result, :status => :unprocessable_entity
  end
  
  # POST /stories/export               Exports stories.
  def export
    response.headers["Content-Disposition"] = 'attachment; filename=stories.csv'
    cookies[:fileDownload] = { :value => true , :path => '/' }
    render :plain => Story.export(conditions)
  end
  
  # GET /stories/num_pages
  def num_pages
    page = get_params.delete(:page)
    render :json => Story.get_num_pages(conditions.clone, STORIES_PER_PAGE, page ? page : 1)
  end
  
  # Split the story (tasks which have not been accepted will automatically be put in the new story).
  # POST /stories/1/split               Creates the new story and moves the unaccepted tasks to it.
  def split
    @old = Story.find(params[:id])
    
    Story.transaction do
      @tasks = @old.tasks.select{|task| !task.is_done}
      @criteria = @old.criteria.select{|criterium| !criterium.accepted?}
      create
      if authorized_for_create?(@record) && @record.errors.empty?
        @record.created_at = @old.created_at
        @record.in_progress_at = @old.in_progress_at
        @record.save( :validate=> false )
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # Wrap story creation in a transaction since sub instances may be created.
  def create
    Story.transaction do
      super
    end
  end
  
  # Update the surveys if the story is unaccepted.
  def update
    Story.transaction do
      @record = get_record
      blocked_before = @record.is_blocked
      done_before = @record.is_done
      should_update = (params["record"] && params["record"]["status_code"] != Status.Done and @record.status_code == Status.Done)
      super
      if should_update
        Survey.update_rankings(@record.project).each {|story| story.save( :validate=> false )}
      end
      if !blocked_before && @record.is_blocked
        @record.send_notification(current_individual, "A story is blocked", @record.blocked_message)
      end
      if !done_before && @record.is_done
        @record.send_notification(current_individual, "A story is done", @record.done_message)
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
  def epics
    render :json => Story.get_epics(conditions)
  end
  
protected

  # Answer descriptor for this type of object
  def record_type
    "Story"
  end

  # Get the records based on the current individual.
  def get_records
    page = get_params.delete(:page)
    Story.get_records(conditions.clone, STORIES_PER_PAGE, page ? page : 1)
  end

  # Answer whether the resulting record is visible
  def record_visible
    cond = session[:conditions]
    if cond
      modified_conditions = {}
      modified_conditions.each_pair do |key,value|
        modified_conditions[key._to_s]= value
      end
      modified_conditions[:id] = @record.id
      Story.get_records(modified_conditions).length == 1
    else
      true
    end
  end

  # Answer the current record based on the current individual.
  def get_record
    story = Story.find(params[:id])
    if story
      story.current_conditions = session[:conditions]
    end
    story
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record][:project_id])
      params[:record][:project_id] = current_individual.project_id
    end
    story = Story.new(params[:record])
    if @tasks
      @tasks.each do |task|
        story.tasks << task
        task.save
      end
    end
    if @criteria
      @criteria.each do |criterium|
        criterium.destroy
      end
    end
    story.update_parent_status
    story
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = params[:record] && params[:record][:project_id]
    if (new_project_id && record.project_id != new_project_id.to_i && (current_individual.role > Individual::ProjectAdmin || (current_individual.role == Individual::ProjectAdmin && record.project.company_id != current_individual.company_id)))
      false # Must be project admin to change project
    else
      super
    end
  end
  
  # Update the record given the params.
  def update_record
    allowed_params = [:name, :description, :acceptance_criteria, :effort, :status_code, :release_id, :iteration_id, :individual_id, :project_id, :is_public, :priority, :user_priority, :team_id, :reason_blocked, :story_id]
    params[:record].keys.each do |key|
      if key.start_with? 'custom_'
        allowed_params.push(key)
      end
    end
    @record.attributes = params.require(:record).permit(allowed_params)
    @record.update_parent_status
  end
end