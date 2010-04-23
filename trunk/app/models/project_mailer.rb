class ProjectMailer < ActionMailer::Base
  # Users can override who to notify.  Note: This is obsolete and remains for backwards compatibility.
  # Instead set the values in config/site_config.yml
  @@who_to_notify = ''
  cattr_accessor :who_to_notify

  # Send a notification on sign up.
  def signup_notification(project)
    setup_email(project)
    @subject     = 'New project on Planigle'
  end
  
  # Override deliver to only attempt if who_to_notify has been set.
  def deliver!(mail = @mail)
    if config_option(:who_to_notify) || who_to_notify != ""
      super
    end
  end
  
  protected

  # Set up common email properties.
  def setup_email(project)
    @recipients  = "#{config_option(:who_to_notify) ? config_option(:who_to_notify) : who_to_notify}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @body[:company] = project.company.name
    @body[:email] = project.individuals.empty? ? "" : project.individuals.first.email
    @content_type = 'text/html'
  end
end
