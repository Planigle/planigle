class IndividualsController < ApplicationController
  before_filter :login_required, :except => :activate

  active_scaffold do |config|
    config.columns = [:project_id, :login, :email, :first_name, :last_name, :activated, :enabled, :role ]
    edit_columns = [:project_id, :login, :password, :password_confirmation, :email, :first_name, :last_name, :enabled, :role ]
    config.columns[:project_id].label = 'Project' 
    config.create.columns = edit_columns
    config.update.columns = edit_columns
    config.list.sorting = {:first_name => 'ASC', :last_name => 'ASC'}
    columns[:activated].sort_by :sql => 'activation_code' 
    config.list_filter.add(:boolean, :enabled, {:label => 'Enabled', :column => :enabled})
    config.export.columns = [:project, :login, :email, :first_name, :last_name, :activated, :enabled ]
    config.columns[:project_id].sort_by :sql => '(select min(name) from projects where id = project_id)'
  end
  
  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save(false)
    end
    redirect_back_or_default('/')
  end

protected

  # If the user is assigned to a project, only show things related to that project.
  def active_scaffold_constraints
    if current_individual and current_individual.role >= Individual::ProjectAdmin
      super.merge({:project_id => project_id})
    else
      super
    end
  end
  
  # Project admins shouldn't be able to see admins.
  def active_scaffold_conditions
    conditions = super
    current_individual.role >= Individual::ProjectAdmin ? merge_conditions( conditions, ['role in (1,2,3)'] ) : conditions
  end
  
  # Only project admins or higher can create individuals.
  def create_authorized?
    if current_individual.role <= Individual::Admin
      true
    elsif current_individual.role <= Individual::ProjectAdmin && (!params[:record] || !params[:record][:project_id] || project_id == params[:record][:project_id].to_i) && (!params[:record] || !params[:record][:role] || params[:record][:role].to_i > Individual::Admin)
      true
    else
      unauthorized
      false
    end
  end
  
  # Catch the case where a project admin is trying to make another user an admin.  Other cases are
  # caught in Individual::authorized_for_update?
  def update_authorized?
    if Individual::ProjectAdmin && (params[:record] && params[:record][:role] == 0)
      unauthorized
      false
    else
      true
    end
  end
end