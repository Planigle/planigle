class StoriesController < ResourceController
  before_filter :login_required
  session :cookie_only => false, :only => [:import, :export]

  # GET /records
  # GET /records.xml
  def index
    respond_to do |format|
      format.iphone do
        iteration = Iteration.find_current(current_individual)
        cond = {}
        if iteration; cond[:iteration_id] = iteration.id; end
        if current_individual.team_id && current_individual.team.project.id == project_id; cond[:team_id] = current_individual.team_id; end
        @records = Story.get_records(current_individual, cond)
        render
      end
      format.xml { @records = get_records; render :xml => @records }
      format.amf { @records = get_records; render :amf => {:time => Time.now.to_s, :records => @records} }
    end
  end
  
  # POST /stories/import               Imports new/existing stories.
  # POST /stories/import.xml
  def import
    errors = nil
    Story.transaction do
      errors = Story.import(current_individual, params['Filedata'].read)
      if errors.detect {|error| !error.empty?}
        raise "Errors importing data"
      end
      render :xml => xml_result("Data was successfully imported")
    end
  rescue
    if errors
      builder = Builder::XmlMarkup.new
      builder.instruct!
      result = builder.errors do
        row = 2 # includes header row
        errors.each do |error|
          if error.full_messages.length>0
            error.full_messages.each {|message| builder.error('Row ' + row.to_s + ': ' + message)}
          end
          row += 1
        end
      end
    else
      result = xml_error("File format is invalid (must be CSV / comma separated values)")
    end
    render :xml => result, :status => :unprocessable_entity
  end
  
  # POST /stories/export               Exports stories.
  # POST /stories/export.xml
  def export
    render :text => Story.export(current_individual, conditions)
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
      if @record.authorized_for_read?(current_individual)
        respond_to do |format|
          format.xml {render :xml => @record }
          format.amf {render :amf => @record }
        end
      else
        unauthorized
      end
    else
      Story.transaction do
        @tasks = @old.tasks.select{|task| !task.accepted?}
        @criteria = @old.criteria.select{|criterium| !criterium.accepted?}
        create
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
      should_update = (params["record"] && params["record"]["status_code"] != Story::Done and @record.status_code == Story::Done)
      super
      if should_update
        Survey.update_rankings(@record.project).each {|story| story.save(false)}
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

protected

  # Answer descriptor for this type of object
  def record_type
    "Story"
  end

  # Get the records based on the current individual.
  def get_records
    time = get_params[:time]
    cond = conditions.clone
    if params[:iteration_id]; cond[:iteration_id] = params[:iteration_id]; end
    page_size = get_params.delete(:page_size)
    page = get_params.delete(:page)
    if (!time || (page && page > 1) || Story.have_records_changed(current_individual, Time.parse(time)))
      Story.get_records(current_individual, cond, page_size, page)
    else
      nil
    end
  end

  # Answer whether the resulting record is visible
  def record_visible
    cond = session[:conditions]
    if cond
      cond[:id] = @record.id
      Story.get_records(current_individual, cond).length == 1
    else
      true
    end
  end

  # Answer the current record based on the current individual.
  def get_record
    story = Story.find(is_amf ? params[0] : params[:id])
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
    story = is_amf ? params[0] : Story.new(params[:record])
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
    story
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = is_amf ? params[0].project_id : params[:record] && params[:record][:project_id]
    if (new_project_id && record.project_id != new_project_id.to_i && (current_individual.role > Individual::ProjectAdmin || (current_individual.role == Individual::ProjectAdmin && record.project.company_id != current_individual.company_id)))
      false # Must be project admin to change project
    else
      super
    end
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.story_id = params[0].story_id
      @record.team_id = params[0].team_id
      @record.name = params[0].name
      @record.description = params[0].description
      @record.reason_blocked = params[0].reason_blocked
      @record.acceptance_criteria = params[0].acceptance_criteria
      @record.project_id = params[0].project_id
      @record.release_id = params[0].release_id
      @record.iteration_id = params[0].iteration_id
      @record.individual_id = params[0].individual_id
      @record.effort = params[0].effort
      @record.status_code = params[0].status_code
      @record.priority = params[0].priority
      @record.is_public = params[0].is_public
      @record.phone_number = params[0].phone_number
      @record.notification_type = params[0].notification_type
    else
      @record.attributes = params[:record] ? params[:record] : {}
    end
  end
end