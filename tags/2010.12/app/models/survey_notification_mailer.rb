class SurveyNotificationMailer < ActionMailer::Base

  # Send a notification.
  def notification(survey)
    setup_email(survey)
  end
  
  protected

  # Set up common email properties.
  def setup_email(survey)
    @subject     = "Someone has completed a Planigle survey for your project"
    @body[:logo] = config_option(:site_logo)
    @body[:survey]  = survey
    @recipients  = "#{survey.project.admin_email_addresses.join(',')}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @content_type = 'text/html'
  end
end
