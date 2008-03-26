require File.dirname(__FILE__) + '/../test_helper'
require 'stories_controller'

# Re-raise errors caught by the controller.
class StoriesController; def rescue_action(e) raise e end; end

class StoriesControllerTest < Test::Unit::TestCase
  fixtures :individuals
  fixtures :stories

  def setup
    @controller = StoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = stories(:first).id
  end

  # Test getting a listing of stories without credentials.
  def test_index_unauthorized
    get :index
    assert_redirected_to :controller => 'sessions', :action => 'new'    
  end
    
  # Test successfully getting a listing of stories.
  def test_index_success
    login_as(individuals(:quentin))
    get :index
    assert_response :success
    assert_template 'index'
  end

  # Test getting the form to create a new story without credentials.
  def test_new_unauthorized
    get :new
    assert_redirected_to :controller => 'sessions', :action => 'new'    
  end
    
  # Test successfully getting the form to create a new story.
  def test_new_success
    login_as(individuals(:quentin))
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:story)
  end

  # Test creating a new story without credentials.
  def test_create_unauthorized
    num_stories = Story.count
    post :create, :story => { :name => 'foo', :status => 'Created' }
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal num_stories, Story.count
  end

  # Test successfully creating a new story.
  def test_create_success
    num_stories = Story.count
    login_as(individuals(:quentin))
    post :create, :story => { :name => 'foo', :status => 'Created' }
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal num_stories + 1, Story.count
  end

  # Test unsuccessfully creating a new story.
  def test_create_failure
    num_stories = Story.count
    login_as(individuals(:quentin))
    post :create, :story => { :name => create_string(41), :status => 'Created' }
    assert_response :success
    assert_template 'new'
    assert_equal num_stories, Story.count
  end

  # Test showing a story without credentials.
  def test_show_unauthorized
    get :show, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test showing a story successfully.
  def test_show_success
    login_as(individuals(:quentin))
    get :show, :id => @first_id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:story)
    assert assigns(:story).valid?
  end

  # Test getting the form to edit a story without credentials.
  def test_edit_unauthorized
    get :edit, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test successfully getting the form to edit a story.
  def test_edit_success
    login_as(individuals(:quentin))
    get :edit, :id => @first_id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:story)
    assert assigns(:story).valid?
  end

  # Test updating a story without credentials.
  def test_update_unauthorized
    new_name = 'bar'
    put :update, :id => @first_id, :story => {:name => new_name}
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert stories(:first).reload.name != new_name
  end

  # Test successfully updating a story.
  def test_update_success
    login_as(individuals(:quentin))
    new_name = 'new'
    put :update, :id => @first_id, :story => {:name => new_name}
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal new_name, stories(:first).reload.name
  end

  # Test updating a story where the update fails.
  def test_update_fails
    login_as(individuals(:quentin))
    new_name = create_string(41)
    put :update, :id => @first_id, :story => {:name => new_name}
    assert_response :success
    assert_template 'edit'
    assert stories(:first).reload.name != new_name
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

  # Test deleting a story without credentials.
  def test_destroy_unauthorized
    delete :destroy, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_nothing_raised {
      Story.find(@first_id)
    }
  end

  # Test successfully deleting a story.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_raise(ActiveRecord::RecordNotFound) {
      Story.find(@first_id)
    }
  end
    
  # Test successfully deleting a story while returning html for the remaining stories.
  def test_destroy_partial
    login_as(individuals(:quentin))
    xhr :delete, :destroy, :id => @first_id
    assert_response :success
    assert_template "_stories"
    assert_raise(ActiveRecord::RecordNotFound) {
      Story.find(@first_id)
    }
  end
end