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
  
  # Test successfully getting a partial list (by iteration)
  def test_list_partial
    login_as(individuals(:quentin))
    xhr :get, :index, {:iteration_id => 1}
    assert_response :success
    assert_template "_embedded_stories"
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
    xhr :put, :sort_stories, :stories => [999, 2, 3]
    assert_response :unprocessable_entity
    assert_template '_stories'
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :story => {:iteration_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :story => {:iteration_id => 999}
    assert_response :success
    assert_template 'edit'
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :story => {:individual_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :story => {:individual_id => 999}
    assert_response :success
    assert_template 'edit'
    assert_not_equal stories(:first).reload.individual_id, 999
  end
end