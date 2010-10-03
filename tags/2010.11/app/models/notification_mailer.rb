class NotificationMailer < ActionMailer::Base

  # Send a notification.
  def notification(project, emailAddresses, subject, message)
    setup_email(project, emailAddresses, subject, message)
  end
  
  protected

  # Set up common email properties.
  def setup_email(project, emailAddresses, subject, message)
    @subject     = "[#{project.name}] " + subject
    @body[:message_to_send]  = "#{message}"
    @recipients  = "#{emailAddresses}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
