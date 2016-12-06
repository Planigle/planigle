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
        reset_session
        render :json => license_agreement, :status => :unprocessable_entity
      end
    else
      render :json => {:error => 'Invalid Credentials'}, :status => :unprocessable_entity
    end
  end  

  # Refresh the data for the current session
  def refresh
    render :json => data(false)
  end

  # Log out
  # DELETE /session
  def destroy
    self.current_individual.forget_me if logged_in?
    cookies.delete :auth_token
    session.delete :individual_id
    reset_session
    render :json => {}, :status => :ok
  end

protected

  # Answer the data for the current user.
  def data(initial)
    parms = get_params
    result = {}
    result['time'] = Time.now.to_s
    if conditions.include?(:project_id)
      show_project(conditions[:project_id])
    end
    if initial
      result['system'] = System.first()
      result['current_individual'] = current_individual
      result['current_individual'].current_user_project = project
      result['current_release'] = current_release
      result['current_iteration'] = current_iteration
    end
    update_stories = false
    if (!parms[:companies] || Company.have_records_changed(current_individual, Time.parse(parms[:companies])))
      result['companies'] = Company.get_records(current_individual)
    end
    if (!parms[:individuals] || Individual.have_records_changed(current_individual, Time.parse(parms[:individuals])))
      update_stories = true
      result['individuals'] = Individual.get_records(current_individual)
      result['individuals'].each {|individual| individual.current_user_project = project}
    end
    if current_individual.project_id
      if (!parms[:releases] || Release.have_records_changed(current_individual, Time.parse(parms[:releases])))
        update_stories = true
        result['current_release'] = current_release
        result['releases'] = Release.get_records(current_individual)
      end
      if (!parms[:iterations] || Iteration.have_records_changed(current_individual, Time.parse(parms[:iterations])))
        update_stories = true
        result['current_iteration'] = current_iteration
        result['iterations'] = Iteration.get_records(current_individual)
      end
      if (update_stories || !parms[:stories] || Story.have_records_changed(current_individual, Time.parse(parms[:stories])))
        result['stories'] = Story.get_records(current_individual, conditions, parms.delete(:page_size), 1)
        if(current_individual.is_premium && current_individual.project != nil)
          result['story_stats'] = Story.get_stats(current_individual, conditions)
        end
      end
    end
    result
  end

  def current_release
    Release.find_current(current_individual)
  end
  
  def current_iteration
    Iteration.find_current(current_individual)
  end
  
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