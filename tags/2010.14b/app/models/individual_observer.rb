class IndividualObserver < ActiveRecord::Observer
  # Send out activation email on creation of a new individual (if not pre-activated).
  def after_create( individual )
    IndividualMailer.deliver_signup_notification( individual ) if not individual.activated?
  end
end
