require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'
require 'project_mailer'

class ProjectMailerTest < ActiveSupport::TestCase
  fixtures :projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.admin_email = 'testxyz@testxyz.com'
    IndividualMailer.site = 'www.testxyz.com'
    ProjectMailer.who_to_notify = 'ksksk@ksdkdaiu.com'
  end

  # Test notification on signup.
  def test_signup_notification
    response = ProjectMailer.create_signup_notification(projects(:first))
    assert_equal IndividualMailer.admin_email, response.from[0]
    assert_equal ProjectMailer.who_to_notify, response.to[0]
    reg = /.*#{projects(:first).name}.*/
    assert_match reg, response.body
  end
end
