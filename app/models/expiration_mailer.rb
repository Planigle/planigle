class ExpirationMailer < ActionMailer::Base

  # Send a notification.
  def notification(company)
    setup_email(company)
  end
  
  protected

  # Set up common email properties.
  def setup_email(company)
    @subject     = "Your Planigle project is about to revert to the community edition"
    @body[:logo] = config_option(:site_logo)
    @body[:premium_expiry]  = "#{company.premium_expiry.strftime('%B %d, %Y')}"
    @recipients  = "#{company.admin_email_addresses.join(',')}"
    @bcc         = "#{config_option(:who_to_notify)}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
