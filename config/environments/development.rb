Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  # Do not eager load code on boot.
  config.eager_load = false
  
  # Show full error reports.
  config.consider_all_requests_local = true
  
  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
  
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false
  
    config.cache_store = :null_store
  end
  
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  
  config.action_mailer.perform_caching = false
  
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  
  # Suppress logger output for asset requests.
  config.assets.quiet = true
  
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  
  
  # Planigle specific
  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :smtp
  
  config.eager_load=false

  # Set logging to debug
  config.log_level = :debug

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