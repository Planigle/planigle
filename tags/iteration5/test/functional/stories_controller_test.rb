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
  fixtures :projects
  fixtures :tasks

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
    assert_template "list"
  end

  # Test changing the sort order without credentials.
  def test_sort_unauthorized
    put :sort, :stories => [1, 2, 3]
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test successfully changing the sort order.
  def test_sort_success
    login_as(individuals(:quentin))
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    put :sort, :stories => [1, 2, 3]
    assert_response :success
    assert_template '_sortable'
    assert_equal [1, 2, 3], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test failure to change the sort order.
  def test_sort_failure
    login_as(individuals(:quentin))
    xhr :put, :sort, :stories => [999, 2, 3]
    assert_response 404
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test getting a split story template without credentials.
  def test_split_get_unauthorized
    get :split, :id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test getting a split story template successfully.
  def test_split_get_success
    login_as(individuals(:quentin))
    get :split, :id => 1
    assert_response :success
    assert_not_nil assigns(resource_symbol)
    assert assigns(resource_symbol).valid?
  end

  # Test splitting a story without credentials.
  def test_split_put_unauthorized
    num = resource_count
    put :split, :id => 1, resource_symbol => (create_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal num, resource_count    
  end

  # Test splitting a story successfully.
  def test_split_put_success
    num = resource_count
    login_as(individuals(:quentin))
    put :split, :id => 1, resource_symbol => (create_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end

  # Test splitting a story unsuccessfully.
  def test_split_put_failure
    num = resource_count
    login_as(individuals(:quentin))
    put :split, :id => 1, resource_symbol => (create_failure_parameters[resource_symbol]) # hack to get around compiler issue
    assert_response :success
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:iteration_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:iteration_id => 999}
    assert_response :success
    assert_template 'update_form'
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 999}
    assert_response :success
    assert_template 'update_form'
    assert_not_equal stories(:first).reload.individual_id, 999
  end
end