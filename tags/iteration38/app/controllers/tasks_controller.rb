class TasksController < ResourceController
  before_filter :login_required

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
    if is_amf
      @record.name = params[0].name
      @record.description = params[0].description
      @record.individual_id = params[0].individual_id
      @record.effort = params[0].effort
      @record.status_code = params[0].status_code
      @record.priority = params[0].priority
    else
      @record.attributes = params[:record]
    end
  end
end