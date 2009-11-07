class NotificationMailer < ActionMailer::Base

  # Send a notification.
  def notification(project, email, message)
    setup_email(project, email, message)
  end
  
  protected

  # Set up common email properties.
  def setup_email(project, email, message)
    @subject     = "[#{project.name}] A story is blocked"
    @body[:message_to_send]  = "#{message}"
    @recipients  = "#{email}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
