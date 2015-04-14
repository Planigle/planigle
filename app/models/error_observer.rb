class ErrorObserver < ActiveRecord::Observer
  # Send out email on creation of a new error.
  def after_create( error )
    ErrorMailer.error_notification( error ).deliver_now
  end
end
