Planigle::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
#  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
#  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  
  config.eager_load=false

  # Set logging to debug
  RAILS_DEFAULT_LOGGER.level = Logger::DEBUG if defined? RAILS_DEFAULT_LOGGER

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