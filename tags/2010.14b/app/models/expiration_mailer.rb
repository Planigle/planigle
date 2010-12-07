class ExpirationMailer < ActionMailer::Base

  # Send a notification.
  def notification(project)
    setup_email(project)
  end
  
  protected

  # Set up common email properties.
  def setup_email(project)
    @subject     = "Your Planigle project is about to revert to the community edition"
    @body[:logo] = config_option(:site_logo)
    @body[:project]  = "#{project.name}"
    @body[:premium_expiry]  = "#{project.premium_expiry.strftime('%B %d, %Y')}"
    @recipients  = "#{project.admin_email_addresses.join(',')}"
    @bcc         = "#{config_option(:who_to_notify)}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
