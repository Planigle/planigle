require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class ProjectsIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :teams
  fixtures :story_attributes

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    CompanyMailer.who_to_notify = 'foo@bar.com'
  end

  # Test getting teams and attributes for a project.
  def test_show_teams_and_attributes
    login_as(individuals(:admin2))
    get resource_url << '/1', params: {}, headers: authorization_header
    assert_response :success
    assert json
  end
end