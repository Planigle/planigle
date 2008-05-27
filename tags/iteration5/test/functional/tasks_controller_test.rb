require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../tasks_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "tasks_controller"

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < ActionController::TestCase
  include ControllerResourceHelper
  include TasksTestHelper

  fixtures :individuals
  fixtures :tasks

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # Test successfully getting a partial list (by story)
  def test_list_partial
    login_as(individuals(:quentin))
    xhr :get, :index, {:story_id => 1}
    assert_response :success
    assert_template "list"
  end
    
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 2}
    assert_redirected_to :action => :index
    assert_equal tasks(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 999}
    assert_response :success
    assert_not_equal tasks(:one).reload.individual_id, 999
  end
end
