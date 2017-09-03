class ReleasesController < ResourceController
  before_action only: [:index, :show] do
    log_in_or_oauth :read
  end
  before_action only: [:create, :update, :destroy] do
    log_in_or_oauth :admin
  end

protected

  # Get the records based on the current individual.
  def get_records
    Release.get_records(current_individual, params[:historical] == 'true')
  end

  # Answer the current record based on the current individual.
  def get_record
    Release.find(params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record][:project_id])
      params[:record][:project_id] = current_individual.project_id
    end
    Release.new(record_params)
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = params[:record][:project_id]
    if (new_project_id && record.project_id != new_project_id.to_i)
      false # Can't change project
    else
      super
    end
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end
  
private
  def record_params
    params.require(:record).permit(:name, :start, :finish, :project_id)
  end
end