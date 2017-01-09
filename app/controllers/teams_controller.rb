class TeamsController < ResourceController
  before_action :login_required

protected

  # Get the records based on the current individual.
  def get_records
    Team.where(project_id: params[:project_id]).order('name')
  end

  # Answer the current record based on the current individual.
  def get_record
    team = Team.find_by(id: params[:id], project_id: params[:project_id])
    if !team; raise ActiveRecord::RecordNotFound.new; end
    team
  end
  
  # Create a new record given the params.
  def create_record
    team = Team.new(record_params)
    team.project_id = params[:project_id]
    team
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
    params.require(:record).permit(:name, :description)
  end
end