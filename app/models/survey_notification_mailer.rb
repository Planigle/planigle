class SurveyNotificationMailer < ActionMailer::Base

  # Send a notification.
  def notification(survey)
    setup_email(survey)
  end
  
protected

  # Set up common email properties.
  def setup_email(survey)
    @logo = Rails.configuration.site_logo
    @survey = survey
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{survey.project.admin_email_addresses.join(',')}",
      subject: "Someone has completed a Planigle survey for your project",
      content_type: 'text/html'
    )
  end
end
