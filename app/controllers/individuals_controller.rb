class IndividualsController < ResourceController
  before_action :login_required, :except => :activate

  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save( :validate=> false )
    end
    redirect_to(Rails.configuration.site_url + '/')
  end

protected

  # Get the records based on the current individual.
  def get_records
    Individual.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Individual.find(params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record].has_key?(:company_id))
      params[:record][:company_id] = current_individual.company_id
    end
    if (!params[:record].has_key?(:project_id))
      params[:record][:project_id] = current_individual.project_id
    end
    Individual.new(record_params)
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_company_id = params[:record][:company_id]
    new_project_ids = params[:record][:project_ids]
    new_project_id = params[:record][:project_id]
    new_role = params[:record][:role]
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
    params.require(:record).permit(:login, :email, :first_name, :last_name, :password, :password_confirmation, :enabled, :role, :last_login, :accepted_agreement, :team_id, :phone_number, :notification_type, :company_id, :selected_project_id, :refresh_interval, :project_ids => [])
  end
end