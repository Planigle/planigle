# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'layouts/login'

  # Login screen or failure to log in from xml
  # GET /sessions/new
  # GET /sessions/new.xml
  def new
    respond_to do |format|
      format.html 
      # Access Denied
      format.xml  { render :xml => xml_error('Invalid Credentials'), :status => 401 }
    end
  end

  # Process login results by creating a session.
  # POST /sessions
  # POST /sessions.xml
  def create
    respond_to do |format|
      self.current_individual = Individual.authenticate(params[:login], params[:password])
      if logged_in?
        if params[:remember_me] == "1"
          self.current_individual.remember_me
          cookies[:auth_token] = { :value => self.current_individual.remember_token , :expires => self.current_individual.remember_token_expires_at }
        end
        format.html { redirect_back_or_default('/') }
        format.xml  { head :created }
      else
        format.html { flash[:notice] = 'Invalid Credentials'; render :action => 'new' }
        format.xml  { render :xml => xml_error('Invalid Credentials'), :status => :unprocessable_entity }
      end
    end
  end

  # Log out
  # DELETE /sessions
  # DELETE /sessions.xml
  def destroy
    respond_to do |format|
      self.current_individual.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      format.html { redirect_back_or_default('/')}
      format.xml { head :ok }
    end
  end
end
