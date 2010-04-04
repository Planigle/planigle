class ProjectsController < ResourceController
  before_filter :login_required
  
protected

  # Get the records based on the current individual.
  def get_records
    Project.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Project.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record].has_key?(:company_id))
      params[:record][:company_id] = current_individual.company_id
    end
    is_amf ? params[0] : Project.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.description = params[0].description
      @record.survey_mode = params[0].survey_mode
      @record.track_actuals = params[0].track_actuals
    else
      @record.attributes = params[:record]
    end
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_premium_expiry = is_amf ? params[0].premium_expiry : params[:record][:premium_expiry]
    new_premium_limit = is_amf ? params[0].premium_limit : params[:record][:premium_limit]
    if (current_individual.role > Individual::Admin && new_premium_expiry && record.premium_expiry != (new_premium_expiry.class == Date ? new_premium_expiry : Date.parse(new_premium_expiry)))
      false # Must be admin to change premium_expiry
    elsif (current_individual.role > Individual::Admin && new_premium_limit && record.premium_limit != new_premium_limit.to_i)
      false # Must be admin to change premium_limit
    else
      super
    end
  end
end