require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IterationsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include IterationsTestHelper

  fixtures :individuals
  fixtures :iterations
  fixtures :projects
  fixtures :stories

  # Re-raise errors caught by the controller.
  class IterationsController; def rescue_action(e) raise e end; end

  # Test getting stories within an iteration.
  def test_show_stories
    get resource_url << '/1', {}, authorization_header
    assert_response :success
    assert_select resource_string
    assert_select 'iteration' do
      assert_select 'stories' do
        assert_select 'story'
      end
    end
  end

  # Test getting stories within an iteration in Flex.
  def test_show_stories_flex
    flex_login
    get resource_url << '/1.xml', {}, flex_header
    assert_response :success
    assert_select resource_string
    assert_select 'iteration' do
      assert_select 'stories' do
        assert_select 'story'
      end
    end
  end
end