require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'

class IndividualMailerTest < Test::Unit::TestCase
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  # Test notification on signup.
  def test_signup_notification
    response = IndividualMailer.create_signup_notification(individuals(:aaron))
    email_reg = /([^@\s]+)@(?:[-_a-zA-Z0-9]+\.)+[a-zA-Z]{2,}/
    assert_match email_reg, response.from[0]
    assert_equal individuals(:aaron).email, response.to[0]
    url_reg = /.*http:\/\/((?:[-_a-zA-Z0-9]+\.)+[a-zA-Z]{2,}?(:\d{2,}))\/activate\/#{individuals(:aaron).activation_code}.*/
    assert_match url_reg, response.body
  end
end
