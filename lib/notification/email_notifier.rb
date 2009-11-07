class Notification::EmailNotifier < Notification::Notifier
  # Notify address that message has been sent.
  def send_notification(project, email, message)
    NotificationMailer.deliver_notification(project, email, message)
  end
end
