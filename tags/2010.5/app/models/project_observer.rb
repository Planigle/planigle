class ProjectObserver < ActiveRecord::Observer
  # Send out email on creation of a new project (if configured).
  def after_create( project )
    ProjectMailer.deliver_signup_notification( project )
  end
end
