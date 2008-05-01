class IndividualsController < ApplicationController
  before_filter :login_required, :except => :activate

  active_scaffold do |config|
    config.columns = [:project_id, :login, :email, :first_name, :last_name, :activated, :enabled ]
    edit_columns = [:project_id, :login, :password, :password_confirmation, :email, :first_name, :last_name, :enabled ]
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
    if project_id
      super.merge({:project_id => project_id})
    else
      super
    end
  end

  # Ensure that you can't take "admin" away from yourself.  This overrides an implementation in active scaffold.
  def do_update
    @record = Individual.find( params[ :id ] )
    project = params[:record][:project_id]
    if(@record == current_individual) && !@record.project && project && project != ''
      @record.errors.add(:project_id, '- You cannot remove your own admin abilities.')
      self.successful = false
    else
      super
    end
  end

  # Ensure that you can't delete yourself.  This overrides an implementation in active scaffold.
  def do_destroy
    @record = Individual.find( params[ :id ] )
    if(@record == current_individual)
      flash[:error] = 'You cannot delete yourself.'
      self.successful = false
    else
      super
    end
  end
  
  # SSL is required for this controller.
  def ssl_required?
    ssl_supported?
  end
end