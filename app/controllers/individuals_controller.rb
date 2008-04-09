class IndividualsController < ApplicationController
  before_filter :login_required, :except => :activate

  active_scaffold do |config|
    config.columns = [:login, :email, :first_name, :last_name, :activated, :enabled ]
    config.create.columns = [:login, :password, :password_confirmation, :email, :first_name, :last_name, :enabled ]
    config.update.columns = [:login, :password, :password_confirmation, :email, :first_name, :last_name, :enabled ]
    config.list.sorting = {:first_name => 'ASC', :last_name => 'ASC'}
    columns[:activated].sort_by :sql => 'activation_code' 
  end
  
  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save(false)
    end
    redirect_back_or_default('/')
  end

private

  # Ensure that you can't delete yourself.
  def do_destroy
    @record = Individual.find( params[ :id ] )
    if(@record == current_individual)
      flash[:error] = 'You cannot delete yourself.'
      self.successful = false
    else
      super
    end
  end
end