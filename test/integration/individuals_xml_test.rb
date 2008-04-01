require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../individuals_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IndividualsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include IndividualsTestHelper

  fixtures :individuals

  # Re-raise errors caught by the controller.
  class IndividualsController; def rescue_action(e) raise e end; end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  # Test that you can't delete yourself.
  def test_destroy_self
    delete resource_url << '/1', {}, authorization_header
    assert_response 422 # Unprocessable Entity
    assert Individual.find_by_login('quentin')
  end

  # Test that you can't delete yourself from Flex.
  def test_destroy_self_flex
    flex_login
    delete resource_url << '/1.xml', {}, flex_header
    assert_response 200 # Success
    assert Individual.find_by_login('quentin')
    assert_select 'errors'
  end
end
