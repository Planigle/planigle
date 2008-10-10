require File.dirname(__FILE__) + '/../test_helper'
require 'notification_mailer'

class NotificationMailerTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  # Test notification.
  def test_notification
    response = NotificationMailer.create_notification('test@test.com', 'test')
    assert_equal PLANIGLE_ADMIN_EMAIL, response.from[0]
    assert_equal 'test@test.com', response.to[0]
    assert_equal 'test', response.body
  end
end
