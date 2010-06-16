class IterationsController < ResourceController
  before_filter :login_required

protected

  # Answer whether records have changed.
  def have_records_changed(time)
    Iteration.have_records_changed(current_individual, time)
  end

  # Get the records based on the current individual.
  def get_records
    Iteration.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Iteration.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record][:project_id])
      params[:record][:project_id] = current_individual.project_id
    end
    is_amf ? params[0] : Iteration.new(params[:record])
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = is_amf ? params[0].project_id : params[:record][:project_id]
    if (new_project_id && record.project_id != new_project_id.to_i)
      false # Can't change project
    else
      super
    end
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.start = params[0].start
      @record.length = params[0].length
      @record.retrospective_results = params[0].retrospective_results
    else
      @record.attributes = params[:record]
    end
  end
end