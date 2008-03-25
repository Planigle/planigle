# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {  
  :address => "<Replace with SMTP Server hostname>",
  :port => 25,
  :domain => "<Replace with SMTP Server domain",
  }

module MailerProperties
  AdminEmail = '<Replace with Admin Email address>'    # The email address to send from
  Site = '<Replace with web site host[:port]>'         # The host[:port] of the server (for URLs)
end