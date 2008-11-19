require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class ProjectsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :teams
  fixtures :story_attributes

  # Re-raise errors caught by the controller.
  class ProjectsController; def rescue_action(e) raise e end; end

  # Test getting teams and attributes for a project.
  def test_show_teams_and_attributes
    get resource_url << '/1', {}, authorization_header
    assert_response :success
    assert_select resource_string
    assert_select 'project' do
      assert_select 'story-attributes' do
        assert_select 'story-attribute'
      end
      assert_select 'teams' do
        assert_select 'team'
      end
    end
  end

  # Test getting teams and attributes for a project in Flex.
  def test_show_teams_and_attributes_flex
    flex_login
    get resource_url << '/1.xml', {}, flex_header
    assert_response :success
    assert_select resource_string
    assert_select 'project' do
      assert_select 'story-attributes' do
        assert_select 'story-attribute'
      end
      assert_select 'teams' do
        assert_select 'team'
      end
    end
  end
end