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
    assert_redirected_to :action => 'show'
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
    post :update, :id => @first_id, :story => {:name => new_name}
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert stories(:first).reload.name != new_name
  end

  # Test successfully updating a story.
  def test_update_success
    login_as(individuals(:quentin))
    new_name = 'new'
    post :update, :id => @first_id, :story => {:name => new_name}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
    assert_equal new_name, stories(:first).reload.name
  end

  # Test updating a story where the update fails.
  def test_update_fails
    login_as(individuals(:quentin))
    new_name = create_string(41)
    post :update, :id => @first_id, :story => {:name => new_name}
    assert_response :success
    assert_template 'edit'
    assert stories(:first).reload.name != new_name
  end

  # Test deleting a story without credentials.
  def test_destroy_unauthorized
    post :destroy, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_nothing_raised {
      Story.find(@first_id)
    }
  end

  # Test successfully deleting a story.
  def test_destroy_success
    login_as(individuals(:quentin))
    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_raise(ActiveRecord::RecordNotFound) {
      Story.find(@first_id)
    }
  end
end