class ExpirationMailer < ActionMailer::Base

  # Send a notification.
  def notification(company)
    setup_email(company)
  end
  
protected

  # Set up common email properties.
  def setup_email(company)
    @logo = Rails.configuration.site_logo
    @premium_expiry = "#{company.premium_expiry.strftime('%B %d, %Y')}"
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{company.admin_email_addresses.join(',')}",
      bcc: "#{Rails.configuration.who_to_notify}",
      subject: "Your Planigle project is about to revert to the community edition",
      content_type: 'text/html'
    )
  end
end
