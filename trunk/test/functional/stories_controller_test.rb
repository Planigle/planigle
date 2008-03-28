require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "stories_controller"

# Re-raise errors caught by the controller.
class StoriesController; def rescue_action(e) raise e end; end

class StoriesControllerTest < Test::Unit::TestCase
  include ControllerResourceHelper
  include StoriesTestHelper

  fixtures :individuals
  fixtures :stories

  def setup
    @controller = StoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test changing the sort order without credentials.
  def test_sort_success_unauthorized
    put :sort_stories, :stories => [1, 2, 3]
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test successfully changing the sort order.
  def test_sort_success
    login_as(individuals(:quentin))
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    put :sort_stories, :stories => [1, 2, 3]
    assert_response :success
    assert_template '_stories'
    assert_equal [1, 2, 3], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test failure to change the sort order.
  def test_sort_failure
    login_as(individuals(:quentin))
    put :sort_stories, :stories => [999, 2, 3]
    assert_response :unprocessable_entity
    assert_template '_stories'
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end
end