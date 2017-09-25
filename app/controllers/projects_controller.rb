class ProjectsController < ResourceController
  before_action only: [:index, :show] do
    log_in_or_oauth :read
  end
  before_action only: [:create, :update, :destroy] do
    log_in_or_oauth :admin
  end

  def create
    Project.transaction do # Statuses updated as well
      super
    end
  end

  def update
    Project.transaction do # Statuses updated as well
      super
    end
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
    project = Project.new(record_params)
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end

  def handle_error(e, message)
    if e.class == ActiveRecord::DeleteRestrictionError
      render :json => {:statuses => ['must not be in use before deleting']}, :status => :unprocessable_entity
    else
      super
    end
  end
  
private
  def record_params
    params.require(:record).permit(
      :company_id, :name, :description, :survey_mode, :track_actuals, :last_notified_of_inactivity, {
        :updated_statuses => [:id, :project_id, :name, :status_code, :ordering, :applies_to_stories, :applies_to_tasks]})
  end
end