# Email settings
ActionMailer::Base.smtp_settings = {  
  :address => "<Replace with SMTP Server hostname>",
  :port => 25,
  :domain => "<Replace with SMTP Server domain>",
  }

PLANIGLE_ADMIN_EMAIL = 'noreply@test.com' # <Replace with Admin Email Address> The email address to send from

require 'individual_mailer'
IndividualMailer.site = '<Replace with web site protocol://host[:port]>' # The protocol://host[:port] of the server (for URLs). Ex. http://www.planigle.com
IndividualMailer.logo = nil                                           # The image tag for your logo '<img height="nnn" width="nnn" src="url"/>'
IndividualMailer.support = nil                                        # Support's email address
IndividualMailer.backlog = nil                                        # The URL for your backlog

require 'project_mailer'
ProjectMailer.who_to_notify = ''                                      # The email address to notify of new projects

require 'notification_mailer'