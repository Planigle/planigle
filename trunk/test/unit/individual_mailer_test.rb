require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'

class IndividualMailerTest < ActiveSupport::TestCase
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
  end

  # Test notification on signup.
  def test_signup_notification
    response = IndividualMailer.create_signup_notification(individuals(:user3))
    assert_equal PLANIGLE_ADMIN_EMAIL, response.from[0]
    assert_equal individuals(:user3).email, response.to[0]
    url_reg = /.*http:\/\/#{IndividualMailer.site}\/activate\/#{individuals(:user3).activation_code}.*/
    assert_match url_reg, response.body
    assert_match /.*enabled for the Premium Edition.*/, response.body
  end
end
