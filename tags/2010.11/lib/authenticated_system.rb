module AuthenticatedSystem
  protected
    # Returns true or false if the individual is logged in.
    # Preloads @current_individual with the individual model if they're logged in.
    def logged_in?
      current_individual
    end

    # Accesses the current individual from the session. 
    def current_individual
      @current_individual ||= (login_from_session || login_from_basic_auth || login_from_cookie)
      Thread.current[:user] = @current_individual
    end

    # Store the given individual id in the session.
    def current_individual=(new_individual)
      session[:individual_id] = new_individual ? new_individual.id : nil
      @current_individual = new_individual
      Thread.current[:user] = @current_individual
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
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
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
      respond_to do |format|
        format.html do
          store_location
          redirect_to :controller => :sessions, :action => :new
        end

        format.iphone do
          store_location
          redirect_to :controller => :sessions, :action => :new
        end
        
        # Added to fix bug where 406 was returned instead of 401 (see http://blogs.thewehners.net/josh/posts/tagged/ruby+on+rails)
        format.xml do
          request_http_basic_authentication 'Web Password'
        end

        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
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

    # Called from #current_individual.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      individual = cookies[:auth_token] && Individual.find_by_remember_token(cookies[:auth_token])
      if individual && individual.remember_token?
        self.current_individual = individual
      end
    end
end
