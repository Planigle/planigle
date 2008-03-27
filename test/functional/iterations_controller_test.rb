require File.dirname(__FILE__) + '/../test_helper'
require 'iterations_controller'

# Re-raise errors caught by the controller.
class IterationsController; def rescue_action(e) raise e end; end

class IterationsControllerTest < Test::Unit::TestCase
  fixtures :individuals
  fixtures :iterations

  def setup
    @controller = IterationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = iterations(:first).id
  end

  # Test getting a listing of iterations without credentials.
  def test_index_unauthorized
    get :index
    assert_redirected_to :controller => 'sessions', :action => 'new'    
  end
    
  # Test successfully getting a listing of iterations.
  def test_index_success
    login_as(individuals(:quentin))
    get :index
    assert_response :success
    assert_template 'index'
  end

  # Test getting the form to create a new iteration without credentials.
  def test_new_unauthorized
    get :new
    assert_redirected_to :controller => 'sessions', :action => 'new'    
  end
    
  # Test successfully getting the form to create a new iteration.
  def test_new_success
    login_as(individuals(:quentin))
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:iteration)
  end

  # Test creating a new iteration without credentials.
  def test_create_unauthorized
    num_iterations = Iteration.count
    post :create, :iteration => { :name => 'foo', :start => Date.today }
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal num_iterations, Iteration.count
  end

  # Test successfully creating a new iteration.
  def test_create_success
    num_iterations = Iteration.count
    login_as(individuals(:quentin))
    post :create, :iteration => { :name => 'foo', :start => Date.today }
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal num_iterations + 1, Iteration.count
  end

  # Test unsuccessfully creating a new iteration.
  def test_create_failure
    num_iterations = Iteration.count
    login_as(individuals(:quentin))
    post :create, :iteration => { :name => create_string(41), :start => Date.today }
    assert_response :success
    assert_template 'new'
    assert_equal num_iterations, Iteration.count
  end
    
  # Test successfully creating a iteration while returning html for the new list of iterations.
  def test_create_partial
    login_as(individuals(:quentin))
    post :create, :iteration => { :name => 'iteration 1', :start => Date.today } # Must follow an iteration with a number at end of name
    num_iterations = Iteration.count
    xhr :post, :create, {}
    assert_response :success
    assert_template "_iterations"
    assert_equal num_iterations+1, Iteration.count
  end

  # Test showing a iteration without credentials.
  def test_show_unauthorized
    get :show, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test showing a iteration successfully.
  def test_show_success
    login_as(individuals(:quentin))
    get :show, :id => @first_id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:iteration)
    assert assigns(:iteration).valid?
  end

  # Test getting the form to edit a iteration without credentials.
  def test_edit_unauthorized
    get :edit, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test successfully getting the form to edit a iteration.
  def test_edit_success
    login_as(individuals(:quentin))
    get :edit, :id => @first_id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:iteration)
    assert assigns(:iteration).valid?
  end

  # Test updating a iteration without credentials.
  def test_update_unauthorized
    new_name = 'bar'
    put :update, :id => @first_id, :iteration => {:name => new_name}
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert iterations(:first).reload.name != new_name
  end

  # Test successfully updating a iteration.
  def test_update_success
    login_as(individuals(:quentin))
    new_name = 'new'
    put :update, :id => @first_id, :iteration => {:name => new_name}
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal new_name, iterations(:first).reload.name
  end

  # Test updating a iteration where the update fails.
  def test_update_fails
    login_as(individuals(:quentin))
    new_name = create_string(41)
    put :update, :id => @first_id, :iteration => {:name => new_name}
    assert_response :success
    assert_template 'edit'
    assert iterations(:first).reload.name != new_name
  end

  # Test deleting a iteration without credentials.
  def test_destroy_unauthorized
    delete :destroy, :id => @first_id
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_nothing_raised {
      Iteration.find(@first_id)
    }
  end

  # Test successfully deleting a iteration.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_raise(ActiveRecord::RecordNotFound) {
      Iteration.find(@first_id)
    }
  end
    
  # Test successfully deleting a iteration while returning html for the remaining iterations.
  def test_destroy_partial
    login_as(individuals(:quentin))
    xhr :delete, :destroy, :id => @first_id
    assert_response :success
    assert_template "_iterations"
    assert_raise(ActiveRecord::RecordNotFound) {
      Iteration.find(@first_id)
    }
  end
end