class InactivityMailer < ActionMailer::Base

  # Send a notification.
  def notification(project, last_login)
    setup_email(project, last_login)
  end
  
  protected

  # Set up common email properties.
  def setup_email(project, last_login)
    @subject     = "It has been a while since you've used Planigle"
    @body[:logo] = config_option(:site_logo)
    @body[:project]  = "#{project.name}"
    @body[:last_login]  = "#{last_login.strftime('%B %d, %Y')}"
    @recipients  = "#{project.admin_email_addresses.join(',')}"
    @bcc         = "#{config_option(:who_to_notify)}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
