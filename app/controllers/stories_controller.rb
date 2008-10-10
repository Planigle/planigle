class StoriesController < ResourceController
  before_filter :login_required
  
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
        create
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
  # Update the surveys if the story is unaccepted.
  def update
    Story.transaction do
      @record = get_record
      blocked_before = @record.is_blocked
      should_update = (params["record"]["status_code"] != Story::Done and @record.status_code == Story::Done)
      super
      if should_update
        Survey.update_rankings(@record.project).each {|story| story.save(false)}
      end
      if !blocked_before && @record.is_blocked && (!current_individual.team_id || current_individual.team_id = @record.team_id)
        current_individual.send_notification(@record.blocked_message)
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

protected

  # Get the records based on the current individual.
  def get_records
    Story.get_records(current_individual, params[:iteration_id])
  end

  # Answer the current record based on the current individual.
  def get_record
    Story.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    story = is_amf ? params[0] : Story.new(params[:record])
    if @tasks
      @tasks.each do |task|
        story.tasks << task
        task.save
      end
    end
    story
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.team_id = params[0].projectteam_id
      @record.name = params[0].name
      @record.description = params[0].description
      @record.reason_blocked = params[0].reason_blocked
      @record.acceptance_criteria = params[0].acceptance_criteria
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
      @record.attributes = params[:record]
    end
  end
end