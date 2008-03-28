# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # Enables the Restful Authentication plug-in

  # before_filter :debug # Uncomment to enable output of debug logging.
  after_filter :change_response_for_flex

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_planigle_session_id'  
  session :secret => "'I'll break your neck like a chicken bone.' - infamous quote"

  # Turn off layouts for xhr (i.e., XmlHttpRequest; i.e., when you're using JavaScript to return partials)
  layout proc{ |c| c.request.xhr? ? false : "application" }

  # Flex wants all responses to be 200
  def change_response_for_flex
    valid_status_codes = [201, 422].collect{|code| interpret_status(code)}
    if request.headers.has_key?('HTTP_X_FLASH_VERSION') && valid_status_codes.include?(response.headers['Status'])
      response.headers['Status'] = interpret_status(200)
    end
  
  # An error has occurred.  Render the error (a string) in xml.
  def xml_error(error)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.errors { builder.error error }
  end
   
  # Add common debugging statements here.  To turn on, uncomment before_filter.
  def debug
    request.headers.each {header| logger.fatal(header)}
  end
end