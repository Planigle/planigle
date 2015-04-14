require File.dirname(__FILE__) + '/../test_helper'
require 'notification_mailer'

class NotificationMailerTest < ActiveSupport::TestCase
  fixtures :projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  # Test notification.
  def test_notification
    response = NotificationMailer.notification(projects(:first), 'test@test.com', 'test', 'test')
    assert_equal PLANIGLE_ADMIN_EMAIL, response.from[0]
    assert_equal 'test@test.com', response.to[0]
    assert_equal 'test', response.body.to_s
  end
end
