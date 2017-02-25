# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_action :login_required, :only => :refresh

  # Process login results by creating a session.
  # POST /session
  def create
    if !logged_in?
      self.current_individual = Individual.authenticate(params[:login], params[:password])
    end
    if logged_in?
      if params[:accept_agreement] == "true" || params[:accept_agreement] == true
        self.current_individual.accepted_agreement = Time.now
      end
      if self.current_individual.accepted_agreement || System.first.license_agreement == ""
        self.current_individual.last_login = Time.now
        self.current_individual.remember_me
        cookies[:auth_token] = { :value => self.current_individual.remember_token , :expires => self.current_individual.remember_token_expires_at }
        self.current_individual.save( :validate=> false )
        render :json => self.current_individual, :status => :created
      else
        log_out
        render :json => license_agreement, :status => :unprocessable_entity
      end
    else
      render :json => {:error => 'Invalid Credentials'}, :status => :unprocessable_entity
    end
  end

  # Log out
  # DELETE /session
  def destroy
    self.current_individual.forget_me if logged_in?
    cookies.delete :auth_token
    log_out
    render :json => {}, :status => :ok
  end

protected
  
  def show_project(project_id)
    if project_id
      project = Project.find(project_id)
      if current_individual.company.projects.include?(project)
        current_individual.selected_project = project
        current_individual.save( :validate=> false )
      end
    end
  end

  # Answer the license agreement (for user's acceptance).
  def license_agreement
    result = {}
    result["error"] = 'You must accept the license agreement to proceed'
    result["agreement"] = System.first().license_agreement
    result
  end
end