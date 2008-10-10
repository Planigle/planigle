class Notification::EmailNotifier < Notification::Notifier
  # Notify address that message has been sent.
  def send_notification(email, message)
    NotificationMailer.deliver_notification(email, message)
  end
end
