class TeamsController < ResourceController
  before_filter :login_required

protected

  # Get the records based on the current individual.
  def get_records
    Team.find(:all, :conditions => ["project_id = ?", params[:project_id]], :order => 'name')
  end

  # Answer the current record based on the current individual.
  def get_record
    team = Team.find(:first, :conditions => ["id = ? and project_id = ?", (is_amf ? params[0] : params[:id]), params[:project_id]])
    if !team; raise ActiveRecord::RecordNotFound.new; end
    team
  end
  
  # Create a new record given the params.
  def create_record
    team = is_amf ? params[0] : Team.new(params[:record])
    team.project_id = params[:project_id]
    team
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.description = params[0].description
      @record.individual_id = params[0].individual_id
      @record.effort = params[0].effort
      @record.status_code = params[0].status_code
    else
      @record.attributes = params[:record]
    end
  end
end