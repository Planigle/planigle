# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # Enables the Restful Authentication plug-in
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  
  # before_action :debug # Uncomment to enable output of debug logging.
  after_action :change_response

protected

  # Answer the current project id (or nil if there is not one).
  def project_id
    current_individual ? current_individual.project_id : nil
  end

  # Answer the current project (or nil if there is not one).
  def project
    current_individual ? current_individual.project : nil
  end
  
  def interpret_status(status)
    Rack::Utils::HTTP_STATUS_CODES[status.to_i] || status.to_s
  end

  # REST applications want create to respond in 201 and errors to be 422.
  def change_response
    if response.headers['Status'] == interpret_status(500)
      response.headers['Status'] = interpret_status(422)
    elsif response.headers['Status'] == interpret_status(200) && request.method == :post
      response.headers['Status'] = interpret_status(201)
    end
  end

  # Render as unauthorized.
  def unauthorized
    status = 401
    render :json => {:error => "You are not authorized to perform that action."}, :status => status
  end
   
  # Add common debugging statements here.  To turn on, uncomment before_action.
  def debug
    request.headers.each {|header| logger.debug(header)}
  end
  
  # Answer parameters regardless of format
  def get_params
    params == nil ? {} : params
  end
  
  # Filter the results
  def conditions
    cond = {
      project_id: project_id
    }
    
    if get_params[:release_id]; cond[:release_id] = get_params[:release_id]; end
    if get_params[:iteration_id]; cond[:iteration_id] = get_params[:iteration_id]; end
    if get_params[:team_id]; cond[:team_id] = get_params[:team_id]; end
    if get_params[:individual_id]; cond[:individual_id] = get_params[:individual_id]; end
    if get_params[:status_code]; cond[:status_code] = get_params[:status_code]; end
    if get_params[:text]; cond[:text] = get_params[:text]; end
    get_params.each do |key, value|
      if key.start_with? 'custom_'; cond[key] = get_params[key]; end
    end
      
    if cond[:release_id] == ""; cond[:release_id] = nil; end
    if cond[:iteration_id] == ""; cond[:iteration_id] = nil; end
    if cond[:team_id] == ""; cond[:team_id] = nil; end
    if cond[:individual_id] == ""; cond[:individual_id] = nil; end
    if cond[:id] && cond[:id][0] == 83; cond[:id] = cond[:id][1..cond[:id].length - 1]; end  # 83 = S
    session[:conditions] = cond
      
    cond = cond.clone
    if get_params[:view_all]; cond[:view_all] = get_params[:view_all] == 'true'; end
    if get_params[:view_epics]; cond[:view_epics] = get_params[:view_epics] == 'true'; end
    if get_params[:story_id]; cond[:story_id] = get_params[:story_id]; end

    if cond[:team_id] == "MyTeam"
      team_id = current_individual.team_id
      if team_id && current_individual.team.project_id == current_individual.project_id
        cond[:team_id] = team_id
      else
        cond.delete(:team_id)
      end
    end

    cond
  end
  
  def project_id
    project_id = get_params[:project_id]
    project_id && current_individual.project_ids.include?(project_id) ? project_id : current_individual.project_id
  end
end