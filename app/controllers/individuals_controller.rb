class IndividualsController < ResourceController
  before_filter :login_required, :except => :activate

  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save( :validate=> false )
    end
    redirect_to(ENV['url_after_activate'] ? ENV['url_after_activate'] : '/')
  end

protected

  # Answer whether records have changed.
  def have_records_changed(time)
    Individual.have_records_changed(current_individual, time)
  end

  # Get the records based on the current individual.
  def get_records
    Individual.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Individual.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record].has_key?(:company_id))
      params[:record][:company_id] = current_individual.company_id
    end
    if (!params[:record].has_key?(:project_id))
      params[:record][:project_id] = current_individual.project_id
    end
    is_amf ? params[0] : Individual.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      # Note: this currently does not handle project ids
      @record.selected_project_id = params[0].selected_project_id
      @record.team_id = params[0].team_id
      @record.login = params[0].login
      @record.password = params[0].password
      @record.password_confirmation = params[0].password_confirmation
      @record.email = params[0].email
      @record.first_name = params[0].first_name
      @record.last_name = params[0].last_name
      @record.enabled = params[0].enabled
      @record.role = params[0].role
      @record.refresh_interval = params[0].refresh_interval
    else
      @record.attributes = params[:record]
    end
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_company_id = is_amf ? params[0].company_id : params[:record][:company_id]
    new_project_ids = is_amf ? params[0].project_ids : params[:record][:project_ids]
    new_project_id = is_amf ? params[0].project_id : params[:record][:project_id]
    new_role = is_amf ? params[0].role : params[:record][:role]
    if (new_company_id && record.company_id != new_company_id.to_i && current_individual.role > Individual::Admin)
      false # Must be project admin to change company
    elsif (new_project_ids && record.project_ids != new_project_ids.to_s && (current_individual.role > Individual::ProjectAdmin || (current_individual.role == Individual::ProjectAdmin && record.company_id != current_individual.company_id)))
      false # Must be project admin to change project
    elsif (new_project_id && record.project_id != new_project_id.to_i && (current_individual.role > Individual::ProjectAdmin || (current_individual.role == Individual::ProjectAdmin && record.company_id != current_individual.company_id)))
      false # Must be project admin to change project
    elsif (current_individual.role == Individual::ProjectAdmin && new_role && new_role.to_i == Individual::Admin)
      false # Project admin can't change user to admin
    elsif (current_individual.role > Individual::ProjectAdmin && new_role && record.role != new_role.to_i)
      false # Must be project admin to change role
    elsif (new_role && record.role != new_role.to_i && record.id == current_individual.id)
      false # Can't change own role
    else
      super
    end
  end
  
private
  def record_params
    params.require(:record).permit(:login, :email, :first_name, :last_name, :password, :password_confirmation, :enabled, :role, :last_login, :accepted_agreement, :team_id, :phone_number, :notification_type, :company_id, :selected_project_id, :refresh_interval)
  end
end