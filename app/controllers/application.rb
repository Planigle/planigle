# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # Enables the Restful Authentication plug-in
  
  # before_filter :debug # Uncomment to enable output of debug logging.
  after_filter :change_response
  around_filter :catch_exceptions

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_planigle_session_id'  
  session :secret => "'I'll break your neck like a chicken bone.' - infamous quote"

  ActiveScaffold.set_defaults do |config|
    config.actions.add :list_filter
    config.actions.add :export
    config.show.link.label=''
    config.list.empty_field_text=''
  end

  # Answer the current project id (or nil if there is not one).
  def project_id
    current_individual ? current_individual.project_id : nil
  end

protected

  # Flex wants all responses to be 200
  # REST applications want create to respond in 201 and errors to be 422.
  def change_response
    if request.headers.has_key?('HTTP_X_FLASH_VERSION')
      valid_status_codes = [201, 422, 500].collect{|code| interpret_status(code)}
      if valid_status_codes.include?(response.headers['Status'])
        response.headers['Status'] = interpret_status(200)
      end
    elsif request.format == Mime::XML
      if response.headers['Status'] == interpret_status(500)
        response.headers['Status'] = interpret_status(422)
      elsif response.headers['Status'] == interpret_status(200) && request.method == :post
        response.headers['Status'] = interpret_status(201)
      end
    end
  end

  # Return a 404 if invalid object.
  def catch_exceptions
    yield
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
  # An error has occurred.  Render the error (a string) in xml.
  def xml_error(error)
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.errors { builder.error error }
  end
   
  # Add common debugging statements here.  To turn on, uncomment before_filter.
  def debug
    request.headers.each {header| logger.debug(header)}
  end
end