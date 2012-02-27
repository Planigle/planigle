class ErrorObserver < ActiveRecord::Observer
  # Send out email on creation of a new error.
  def after_create( error )
    ErrorMailer.deliver_error_notification( error )
  end
end
