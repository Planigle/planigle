# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_action :login_required, :only => :refresh

  def main
    puts Rails.configuration.site_url
    redirect_to(Rails.configuration.site_url + '/')
  end
  
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
        if self.current_individual.team && self.current_individual.team.project != self.current_individual.project
          self.current_individual.team = nil # while looking at another project, current team isn't visible
        end
        render :json => self.current_individual, :status => :created
      else
        log_out
        render :json => license_agreement, :status => :unprocessable_entity
      end
    else
      render :json => {:error => params[:password] != '' ? 'Invalid Credentials' : 'Invalid Token'}, :status => :unprocessable_entity
    end
  end

  # Send the email associated with the specified login a temporary URL so that they can log in.
  # POST /session/reset_password
  def reset_password
    individual = Individual.find_by_login(params[:login])
    if individual
      individual.forgot_password
      individual.save( :validate=> false )
      ForgotMailer.notification(individual).deliver_now
    end
  end

  # Log out
  # DELETE /session
  def destroy
    if logged_in?
      self.current_individual.forget_me
      self.current_individual.save( :validate=> false )
    end
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