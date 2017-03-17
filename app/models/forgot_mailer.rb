class ForgotMailer < ActionMailer::Base

  # Send a notification.
  def notification(individual)
    setup_email(individual)
  end
  
protected

  # Set up common email properties.
  def setup_email(individual)
    @site = Rails.configuration.site_url
    @logo = Rails.configuration.site_logo
    @login = individual.login
    @token = individual.forgot_token
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{individual.email}",
      subject: "Forgot your password?",
      content_type: 'text/html'
    )
  end
end
