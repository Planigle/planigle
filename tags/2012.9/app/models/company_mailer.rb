class CompanyMailer < ActionMailer::Base
  # Users can override who to notify.  Note: This is obsolete and remains for backwards compatibility.
  # Instead set the values in config/site_config.yml
  @@who_to_notify = ''
  cattr_accessor :who_to_notify

  # Send a notification on sign up.
  def signup_notification(company, project, individual)
    setup_email(company, project, individual)
    @subject     = 'New company on Planigle'
  end
  
  # Override deliver to only attempt if who_to_notify has been set.
  def deliver!(mail = @mail)
    if config_option(:who_to_notify) || who_to_notify != ""
      super
    end
  end
  
  protected

  # Set up common email properties.
  def setup_email(company, project, individual)
    @recipients  = "#{config_option(:who_to_notify) ? config_option(:who_to_notify) : who_to_notify}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @body[:logo] = config_option(:site_logo)
    @body[:company] = company
    @body[:project] = project
    @body[:individual] = individual
    @content_type = 'text/html'
  end
end
