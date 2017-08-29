require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'
require 'company_mailer'

class CompanyMailerTest < ActiveSupport::TestCase
  fixtures :companies
  fixtures :projects
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    CompanyMailer.who_to_notify = 'test@example.com'
  end

  # Test notification on signup.
  def test_signup_notification
    response = CompanyMailer.signup_notification(companies(:first), projects(:first), individuals(:aaron))
    assert_equal PLANIGLE_ADMIN_EMAIL, response.from[0]
    assert_equal 'test@example.com', response.to[0]
    reg = /.*#{projects(:first).company.name}.*/
    assert_match reg, response.body.to_s
  end
end
