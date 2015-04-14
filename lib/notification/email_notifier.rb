class Notification::EmailNotifier < Notification::Notifier
  # Notify address that message has been sent.
  def send_notification(project, email, subject, message)
    begin
      NotificationMailer.notification(project, email, subject, message).deliver_now
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.error(e)
      RAILS_DEFAULT_LOGGER.error(e.backtrace.join("\n"))
    end
  end
end
