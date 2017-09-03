module AuthenticatedSystem
  protected
  def log_in_or_oauth(level)
    authorized? || doorkeeper_authorize!(level) || access_denied
  end
  
  # Returns true or false if the individual is logged in.
  # Preloads @current_individual with the individual model if they're logged in.
  def logged_in?
    current_individual
  end

  # Accesses the current individual from the session.
  def current_individual
    @current_individual ||= (login_from_session || login_from_basic_auth || login_from_forgot_token || login_from_cookie || login_from_doorkeeper)
    Thread.current[:user] = @current_individual
  end

  # Store the given individual id in the session.
  def current_individual=(new_individual)
    session[:individual_id] = new_individual ? new_individual.id : nil
    @current_individual = new_individual
    Thread.current[:user] = @current_individual
  end
  
  def log_out
    session[:individual_id] = nil
  end

  # Check if the individual is authorized
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the individual
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorized?
  #    current_individual.login != "bob"
  #  end
  def authorized?
    logged_in?
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_action :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_action :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_action :login_required
  #
  def login_required
    authorized? || access_denied
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the individual is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    render :json => {error: 'You must be logged in'}, status: 401
  end

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Inclusion hook to make #current_individual and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_individual, :logged_in?
  end

  # Called from #current_individual.  First attempt to login by the individual id stored in the session.
  def login_from_session
    self.current_individual = Individual.find_by_id(session[:individual_id]) if session[:individual_id]
  end

  # Called from #current_individual.  Now, attempt to login by basic authentication information.
  def login_from_basic_auth
    authenticate_with_http_basic do |username, password|
      self.current_individual = Individual.authenticate(username, password)
    end
  end

  # Called from #current_individual.  Attempt to login by a token.
  def login_from_forgot_token
    individual = params[:token] && Individual.find_by_forgot_token(params[:token])
    if individual && individual.login == params[:login] && Time.now.utc < individual.forgot_token_expires_at
      individual.clear_forgot_password
      individual.save( :validate=> false )
      self.current_individual = individual
    end
  end

  # Called from #current_individual.  Attempt to login by an expiring token in the cookie.
  def login_from_cookie
    individual = cookies[:auth_token] && Individual.find_by_remember_token(cookies[:auth_token])
    if individual && individual.remember_token?
      self.current_individual = individual
    end
  end

  # Called from #current_individual.  Finally, attempt to login through doorkeeper.
  def login_from_doorkeeper
    self.current_individual = Individual.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
