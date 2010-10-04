class TasksController < ResourceController
  before_filter :login_required

  # Notify of key changes.
  def update
    Task.transaction do
      @record = get_record
      story = @record.story
      was_ready_to_accept_before = story.is_ready_to_accept
      super
      if !was_ready_to_accept_before && story.reload.is_ready_to_accept
        story.send_notification("All tasks for a story are done", story.ready_to_accept_message)
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

protected

  # Get the records based on the current individual.
  def get_records
    Task.find(:all, :conditions => ["story_id = ?", params[:story_id]], :order => 'status_code desc, name')
  end

  # Answer the current record based on the current individual.
  def get_record
    task = Task.find(:first, :conditions => ["id = ? and story_id = ?", (is_amf ? params[0] : params[:id]), params[:story_id]])
    if !task; raise ActiveRecord::RecordNotFound.new; end
    task
  end
  
  # Create a new record given the params.
  def create_record
    task = is_amf ? params[0] : Task.new(params[:record])
    task.story_id = params[:story_id]
    task
  end
  
  # Update the record given the params.
  def update_record
    old_status = @record.status_code
    if is_amf
      @record.name = params[0].name
      @record.description = params[0].description
      @record.individual_id = params[0].individual_id
      @record.effort = params[0].effort
      @record.estimate = params[0].estimate
      @record.actual = params[0].actual
      @record.status_code = params[0].status_code
      @record.priority = params[0].priority
      effort = params[0].effort
      status = params[0].status_code
      owner = params[0].individual_id
    else
      @record.attributes = params[:record]
      if (params[:record])
        effort = params[:record][:effort]
        status = params[:record][:status_code]
        owner = params[:record][:individual_id]
      end
    end
    if @record.status_code == Story::Done && effort == nil
      @record.effort = 0
    end
    if old_status == Story::Created && status != nil && status != Story::Created && @record.individual_id == nil && owner == nil
      @record.individual_id = current_individual.id
    end
  end
end