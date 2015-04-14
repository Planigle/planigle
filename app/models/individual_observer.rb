class IndividualObserver < ActiveRecord::Observer
  # Send out activation email on creation of a new individual (if not pre-activated).
  def after_create( individual )
    IndividualMailer.signup_notification( individual ).deliver_now if not individual.activated?
  end
end
