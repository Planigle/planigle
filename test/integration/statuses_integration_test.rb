require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../releases_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StatusesIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include StatusesTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects

  # Test a successful delete /resources/id request.
  def test_destroy_success
    login_as(individuals(:admin2))
    delete resource_url << '/17', params: {}, headers: authorization_header
    assert_response 200 # Success
    assert_delete_succeeded
  end
end