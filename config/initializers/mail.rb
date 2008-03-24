# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {  
  :address => "smtp-server.austin.rr.com",
  :port => 25,
  :domain => "austin.rr.com",
  }

module MailerProperties
  AdminEmail = 'wbodwell@austin.rr.com'    # The email address to send from
  Site = 'www.planigle.com:3001'           # The host[:port] of the server (for URLs)
end