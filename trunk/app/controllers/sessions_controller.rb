# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'layouts/login'

  # Login screen or failure to log in from xml
  def new
    respond_to do |format|
      format.html 
      # Access Denied
      format.xml  { render :xml => "Invalid Credentials", :status => 401 }
    end
  end

  # Process login results by creating a session.
  def create
    self.current_individual = Individual.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_individual.remember_me
        cookies[:auth_token] = { :value => self.current_individual.remember_token , :expires => self.current_individual.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      flash[:notice] = "Invalid Credentials"
      render :action => "new"
    end
  end

  # Log out
  def destroy
    self.current_individual.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
end
