Postevent::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
#  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

  config.eager_load=true

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp

  # Set notification
  PLANIGLE_EMAIL_NOTIFIER = Notification::EmailNotifier.new
  PLANIGLE_SMS_NOTIFIER = Notification::Notifier.new

  # Whether LDAP should be used for authentication; if true you must set the next few values
  config.use_ldap = false

  # Host name of the LDAP server (ignored if LDAP not in use)
  config.ldap_host = "<FQDN of LDAP Server>"
  
  # Port of the LDAP server (ignored if LDAP not in use)
  config.ldap_port = 389
  
  # Domain suffic to look up on the LDAP server (ignored if LDAP not in use)
  config.domain_suffix = "@<company name>.com"
  
  # Criteria for searching the LDAP server (ignored if LDAP not in use)
  config.ldap_search_base = "ou=people,dc=<company name>,dc=com"

  # The number of days without logging in to be considered inactive and notified (blank=no notification)
  config.notify_of_inactivity_after = nil

  # The maximum number of days to be notified of inactivity (blank=no maximum; useful when first enabling notification)
  config.notify_of_inactivity_before = nil

  # The number of days before expiration to notify (blank=no notification)
  config.notify_when_expiring_in = nil

  # The protocol://host[:port] of the server (for URLs). Ex. http://www.planigle.com
  config.site_url = '<Replace with web site protocol://host[:port]>'
  
  # The image tag for your logo '<img height="nnn" width="nnn" src="url"/>'
  config.site_logo = nil

  # Support's email address
  config.support_email = nil

  # The URL for your backlog
  config.backlog_url = nil

  # The email address to notify of things going on with projects (creation, expiration, inactivity; blank=no one)
  config.who_to_notify = nil
end