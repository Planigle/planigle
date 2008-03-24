# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # Enables the Restful Authentication plug-in

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_planigle_session_id'  
  session :secret => "'I'll break your neck like a chicken bone.' - infamous quote"
end
