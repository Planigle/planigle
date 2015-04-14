class InactivityMailer < ActionMailer::Base

  # Send a notification.
  def notification(project, last_login)
    setup_email(project, last_login)
  end
  
  protected

  # Set up common email properties.
  def setup_email(project, last_login)
    @logo = Rails.configuration.site_logo
    @project = "#{project.name}"
    @last_login = "#{last_login.strftime('%B %d, %Y')}"
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{project.admin_email_addresses.join(',')}",
      bcc: "#{Rails.configuration.who_to_notify}",
      subject: "It has been a while since you've used Planigle",
      content_type: 'text/html'
    )
  end
end
