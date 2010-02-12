class IndividualMailer < ActionMailer::Base

  # Users can override the site URL.
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
    @subject     = 'Please activate your new account'
    @body[:url]  = "#{site}/activate/#{individual.activation_code}"
    @body[:logo] = logo
    @body[:support] = support
    @body[:backlog] = backlog
  end
  
  protected

  # Set up common email properties.
  def setup_email(individual)
    @recipients  = "#{individual.email}"
    @from        = "#{PLANIGLE_ADMIN_EMAIL}"
    @sent_on     = Time.now
    @body[:project] = individual.project
    @body[:individual] = individual
    @content_type = 'text/html'
  end
end
