class IndividualMailer < ActionMailer::Base

  # Users can override the site URL.  Note: This is obsolete and remains for backwards compatibility.
  @@site = ''
  cattr_accessor :site
  @@logo = ''
  cattr_accessor :logo
  @@support = ''
  cattr_accessor :support
  @@backlog = ''
  cattr_accessor :backlog

  # Send a notification on sign up.
  def signup_notification(individual)
    setup_email(individual)
  end
  
  protected

  # Set up common email properties.
  def setup_email(individual)
    @url = "#{Rails.configuration.site_url ? Rails.configuration.site_url : site}/activate/#{individual.activation_code}"
    @logo = Rails.configuration.site_logo ? Rails.configuration.site_logo : logo
    @support = Rails.configuration.support_email ? Rails.configuration.support_email : support
    @backlog = Rails.configuration.backlog_url ? Rails.configuration.backlog_url : backlog
    @project = individual.project
    @individual = individual
    mail(
      from: "#{PLANIGLE_ADMIN_EMAIL}",
      to: "#{individual.email}",
      bcc: "#{Rails.configuration.who_to_notify}",
      subject: 'Please activate your new account',
      content_type: 'text/html'
    )
  end
end
