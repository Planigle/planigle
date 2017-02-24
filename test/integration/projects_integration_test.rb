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

  # Re-raise errors caught by the controller.
  class ProjectsController; def rescue_action(e) raise e end; end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    CompanyMailer.who_to_notify = 'foo@bar.com'
  end

  # Test getting teams and attributes for a project.
  def test_show_teams_and_attributes
    get resource_url << '/1', params: {}, headers: authorization_header
    assert_response :success
    assert_select resource_string
    assert_select 'project' do
      assert_select 'filtered-attributes' do
        assert_select 'filtered-attribute'
      end
      assert_select 'teams' do
        assert_select 'team'
      end
    end
  end
end