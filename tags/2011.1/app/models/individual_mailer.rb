class IndividualMailer < ActionMailer::Base

  # Users can override the site URL.  Note: This is obsolete and remains for backwards compatibility.
  # Instead set the values in config/site_config.yml
  @@site = ''
  cattr_accessor :site
  @@logo = ''
  cattr_accessor :logo
  @@support = ''
  cattr_accessor :support
  @@backlog = ''
  cattr_accessor :backlog

  # Send a notification on sign up.
  def signup_notification(individual)
    setup_email(individual)
    @subject     = 'Please activate your new account'
    @body[:url]  = "#{config_option(:site_url) ? config_option(:site_url) : site}/activate/#{individual.activation_code}"
    @body[:logo] = config_option(:site_logo) ? config_option(:site_logo) : logo
    @body[:support] = config_option(:support_email) ? config_option(:support_email) : support
    @body[:backlog] = config_option(:backlog_url) ? config_option(:backlog_url) : backlog
  end
  
  protected

  # Set up common email properties.
  def setup_email(individual)
    @recipients  = "#{individual.email}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @body[:project] = individual.project
    @body[:individual] = individual
    @content_type = 'text/html'
  end
end
