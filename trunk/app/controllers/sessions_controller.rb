# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :only => :refresh

  # Login screen or failure to log in from xml
  # GET /sessions/new
  # GET /sessions/new.xml
  def new
    respond_to do |format|
      format.iphone
      format.xml { render :xml => xml_error('Invalid Credentials'), :status => 401 }
    end
  end

  # Process login results by creating a session.
  # POST /sessions
  # POST /sessions.xml
  def create
    respond_to do |format|
      info = is_amf ? params[0] : params
      self.current_individual = Individual.authenticate(info[:login], info[:password])
      if logged_in?
        if info[:accept_agreement] == "true" || info[:accept_agreement] == true
          self.current_individual.accepted_agreement = Time.now
        end
        if self.current_individual.accepted_agreement || System.find(:first).license_agreement == "" || request.format == :iphone
          self.current_individual.last_login = Time.now
          if info[:remember_me] == "true" || info[:remember_me] == true
            self.current_individual.remember_me
            cookies[:auth_token] = { :value => self.current_individual.remember_token , :expires => self.current_individual.remember_token_expires_at }
          end
          self.current_individual.save(false)
          format.iphone do
            if self.current_individual.is_premium
              redirect_to :controller => :stories, :action => :index
            else
              flash[:notice] = 'You must be a premium customer to use the IPhone interface'
              render :action => 'new'
            end
          end
          format.xml { render :xml => data(true), :status => :created }
          format.amf { render :amf => data(true) }
        else
          reset_session
          format.xml { render :xml => license_agreement, :status => :unprocessable_entity }
          format.amf { render :amf => license_agreement }
        end
      else
        format.iphone { flash[:notice] = 'Invalid Credentials'; render :action => 'new' }
        format.xml { render :xml => xml_error('Invalid Credentials'), :status => :unprocessable_entity }
        format.amf { render :amf => {:error => 'Invalid Credentials'} }
      end
    end
  end

  # Refresh the data for the current session
  def refresh
    respond_to do |format|
      format.xml { render :xml => data(false)}
      format.amf { render :amf => data(false)}
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
      format.iphone { redirect_to :controller => :sessions, :action => :new }
      format.xml { head :ok }
      format.amf { render :amf => 'success' }
    end
  end

protected

  # Answer the data for the current user.
  def data(initial)
    parms = get_params
    result = {}
    result['time'] = Time.now.to_s
    if initial
      result['system'] = System.find(:first)
      result['current_individual'] = current_individual
    end
    update_stories = false
    if (!parms[:companies] || Company.have_records_changed(current_individual, Time.parse(parms[:companies])))
      result['companies'] = Company.get_records(current_individual)
    end
    if (!parms[:individuals] || Individual.have_records_changed(current_individual, Time.parse(parms[:individuals])))
      update_stories = true
      result['individuals'] = Individual.get_records(current_individual)
    end
    if current_individual.project_id
      if (!parms[:releases] || Release.have_records_changed(current_individual, Time.parse(parms[:releases])))
        update_stories = true
        result['releases'] = Release.get_records(current_individual)
      end
      if (!parms[:iterations] || Iteration.have_records_changed(current_individual, Time.parse(parms[:iterations])))
        update_stories = true
        result['iterations'] = Iteration.get_records(current_individual)
      end
      if (update_stories || !parms[:stories] || Story.have_records_changed(current_individual, Time.parse(parms[:stories])))
        result['stories'] = Story.get_records(current_individual, parms[:conditions] ? parms[:conditions] : {:status_code => 'NotDone', :team_id => 'MyTeam', :release_id => 'Current', :iteration_id => 'Current'})
      end
    end
    result
  end

  # Answer the license agreement (for user's acceptance).
  def license_agreement
    result = {}
    result["error"] = 'You must accept the license agreement to proceed'
    result["agreement"] = System.find(:first).license_agreement
    result
  end
end