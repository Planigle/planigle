require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'


class IndividualMailerTest < ActiveSupport::TestCase
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.admin_email = 'testxyz@testxyz.com'
    IndividualMailer.site = 'www.testxyz.com'
  end

  # Test notification on signup.
  def test_signup_notification
    response = IndividualMailer.create_signup_notification(individuals(:aaron))
    assert_equal IndividualMailer.admin_email, response.from[0]
    assert_equal individuals(:aaron).email, response.to[0]
    url_reg = /.*http:\/\/#{IndividualMailer.site}\/activate\/#{individuals(:aaron).activation_code}.*/
    assert_match url_reg, response.body
  end
end
