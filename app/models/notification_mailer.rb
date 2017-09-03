class NotificationMailer < ActionMailer::Base

  # Send a notification.
  def notification(project, emailAddresses, subject, message)
    setup_email(project, emailAddresses, subject, message)
  end
  
protected

  # Set up common email properties.
  def setup_email(project, emailAddresses, subject, message)
    @message_to_send = "#{message}"
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{emailAddresses}",
      subject: "[#{project.name}] " + subject,
      content_type: 'text/html'
    ) do |format|
      format.html { render plain: @message_to_send }
    end
  end
end
