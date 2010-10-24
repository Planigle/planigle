# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # Enables the Restful Authentication plug-in

  acts_as_iphone_controller

  # Don't display password in log
  filter_parameter_logging :password, :password_confirmation

  # before_filter :debug # Uncomment to enable output of debug logging.
  after_filter :change_response

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_planigle_session_id'  
  session :secret => "'I'll break your neck like a chicken bone.' - infamous quote"

protected

  # Answer the current project id (or nil if there is not one).
  def project_id
    current_individual ? current_individual.project_id : nil
  end

  # Answer the current project (or nil if there is not one).
  def project
    current_individual ? current_individual.project : nil
  end

  # Flex wants all responses to be 200
  # REST applications want create to respond in 201 and errors to be 422.
  def change_response
    if is_web_service
      if response.headers['Status'] == interpret_status(500)
        response.headers['Status'] = interpret_status(422)
      elsif response.headers['Status'] == interpret_status(200) && request.method == :post
        response.headers['Status'] = interpret_status(201)
      end
    else
      valid_status_codes = [201, 401, 422, 500].collect{|code| interpret_status(code)}
      if valid_status_codes.include?(response.headers['Status'])
        response.headers['Status'] = interpret_status(200)
      end
    end
  end

  # Answer if response codes should be tailored to a web service (not Flex).
  def is_web_service
    request.format == Mime::XML && (!request.path.include?('.xml') || request.user_agent == 'Rails Testing') # Flex works around lack of Accept header by requesting .xml.
  end

  # Render as unauthorized (note that since this is frequently called in a filter that cancels future
  # filters, we need to make sure we return a status code that Flex will like (if in use).
  def unauthorized
    status = is_web_service ? 401 : 200 # Flex works around lack of Accept header by requesting .xml.
    respond_to do |format|
      format.xml { render :xml => xml_error("You are not authorized to perform that action."), :status => status }
      format.amf { render :amf => ["You are not authorized to perform that action."] }
    end
  end

  # A successful result has occurred.  Render the success message (a string) in xml.
  def xml_result(result)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.results { builder.result result }
  end
  
  # An error has occurred.  Render the error (a string) in xml.
  def xml_error(error)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.errors { builder.error error }
  end
   
  # Add common debugging statements here.  To turn on, uncomment before_filter.
  def debug
    request.headers.each {|header| logger.debug(header)}
  end
  
  # Answer parameters regardless of format
  def get_params
    parms = is_amf ? params[0] : params[:record]
    parms == nil ? {} : parms
  end
end