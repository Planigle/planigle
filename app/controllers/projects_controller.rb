class ProjectsController < ResourceController
  before_action only: [:index, :show] do
    log_in_or_oauth :read
  end
  before_action only: [:create, :update, :destroy] do
    log_in_or_oauth :admin
  end
  
protected

  # Get the records based on the current individual.
  def get_records
    Project.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Project.find(params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record].has_key?(:company_id))
      params[:record][:company_id] = current_individual.company_id
    end
    Project.new(record_params)
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end
  
private
  def record_params
    params.require(:record).permit(:company_id, :name, :description, :survey_mode, :track_actuals, :last_notified_of_inactivity)
  end
end