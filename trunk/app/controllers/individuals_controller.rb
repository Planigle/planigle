class IndividualsController < ResourceController
  before_filter :login_required, :except => :activate

  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save(false)
    end
    redirect_to(ENV['url_after_activate'] ? ENV['url_after_activate'] : '/')
  end

protected

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
    is_amf ? params[0] : Individual.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.project_id = params[0].project_id
      @record.login = params[0].login
      @record.password = params[0].password
      @record.password_confirmation = params[0].password_confirmation
      @record.email = params[0].email
      @record.first_name = params[0].first_name
      @record.last_name = params[0].last_name
      @record.enabled = params[0].enabled
      @record.role = params[0].role
    else
      @record.attributes = params[:record]
    end
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = is_amf ? params[0].project_id : params[:record][:project_id]
    new_role = is_amf ? params[0].role : params[:record][:role]
    if (current_individual.role > Individual::Admin && new_project_id && record.project_id != new_project_id.to_i)
      false # Must be admin to change project
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
end