class ErrorMailer < ActionMailer::Base
  # Users can override who to notify.  Note: This is obsolete and remains for backwards compatibility.
  # Instead set the values in config/site_config.yml
  @@who_to_notify = ''
  cattr_accessor :who_to_notify

  # Send a notification on sign up.
  def error_notification(error)
    setup_email(error)
    @subject     = 'Error in Planigle'
  end
  
  # Override deliver to only attempt if who_to_notify has been set.
  def deliver!(mail = @mail)
    if config_option(:who_to_notify) || who_to_notify != ""
      super
    end
  end
  
  protected

  # Set up common email properties.
  def setup_email(error)
    @recipients  = "#{config_option(:who_to_notify) ? config_option(:who_to_notify) : who_to_notify}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @body[:error] = error
    @content_type = 'text/html'
  end
end
