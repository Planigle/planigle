# Email settings
ActionMailer::Base.smtp_settings = {  
  :address => "<Replace with SMTP Server hostname>",
  :port => 25,
  :domain => "<Replace with SMTP Server domain>",
  }

PLANIGLE_ADMIN_EMAIL = 'noreply@test.com' # <Replace with Admin Email Address> The email address to send from