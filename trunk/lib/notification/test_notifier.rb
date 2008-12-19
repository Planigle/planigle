class Notification::TestNotifier < Notification::Notifier
  @number_of_notifications = 0

  # Notify address that message has been sent.
  def send_notification(address, message)
    @number_of_notifications = @number_of_notifications ? @number_of_notifications + 1 : 1
  end
  
  # Answer the number of notifications that have been sent.
  def number_of_notifications
    @number_of_notifications || 0
  end
  
  # Reset the number of notifications.
  def reset_notifications
    @number_of_notifications = 0
  end
end