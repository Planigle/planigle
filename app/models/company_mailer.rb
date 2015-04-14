class CompanyMailer < ActionMailer::Base
  # Users can override who to notify.  Note: This is obsolete and remains for backwards compatibility.
  @@who_to_notify = ''
  cattr_accessor :who_to_notify

  # Send a notification on sign up.
  def signup_notification(company, project, individual)
    setup_email(company, project, individual)
  end
  
  # Override deliver to only attempt if who_to_notify has been set.
  def deliver!(mail = @mail)
    if Rails.configuration.who_to_notify || who_to_notify != ""
      super
    end
  end
  
protected

  # Set up common email properties.
  def setup_email(company, project, individual)
    @logo = Rails.configuration.site_logo
    @company = company
    @project = project
    @individual = individual
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{Rails.configuration.who_to_notify ? Rails.configuration.who_to_notify : who_to_notify}",
      subject: 'New company on Planigle',
      content_type: 'text/html'
    )
  end
end
