require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../tasks_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "tasks_controller"

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < ActionController::TestCase
  include ControllerResourceHelper
  include TasksTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :tasks
    
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 2}, :story_id => 1
    assert_response :success
    assert_equal tasks(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 999}, :story_id => 1
    assert_response :success
    assert_not_equal tasks(:one).reload.individual_id, 999
  end

  # Test getting tasks (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Story.find_all_by_project_id(1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Story.find_all_by_project_id(1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Story.find_all_by_project_id(1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Story.find_all_by_project_id(1).inject(0){|sum, story| sum + story.tasks.length})
  end

  # Test getting tasks (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml', :story_id => 1
    assert_response :success
    assert_select "tasks" do
      assert_select "task", count
    end
  end

  # Test showing a task for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 3, :format => 'xml', :story_id => 5
    assert_response 401
  end
    
  # Test creating tasks (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating tasks (based on role).
  def test_create_by_project_user
    create_by_role_successful(individuals(:user))
  end
    
  # Test creating tasks (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a task for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    post :create, create_success_parameters.merge( :format => 'xml', :story_id => '5' )
    assert_response 401
    assert_equal num, resource_count
  end

  # Create successfully based on role.
  def create_by_role_successful( user )
    login_as(user)
    num = resource_count
    post :create, create_success_parameters.merge( :format => 'xml' )
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
  end    
  
  # Create unsuccessfully based on role.
  def create_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    post :create, create_success_parameters.merge( :format => 'xml' )
    assert_response 401
    assert_equal num, resource_count
    assert_select "errors"
  end
    
  # Test updating tasks (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating tasks (based on role).
  def test_update_by_project_user
    update_by_role_successful(individuals(:user))
  end
    
  # Test updating tasks (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a task for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put :update, update_success_parameters.merge({:id => 3, :story_id => 5, :format => 'xml'})
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(update_success_parameters)
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select "errors"
  end
    
  # Test deleting tasks (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting tasks (based on role).
  def test_delete_by_project_user
    delete_by_role_successful(individuals(:user))
  end
    
  # Test deleting tasks (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete :destroy, :id => 3, :format => 'xml', :story_id => 5
    assert_response 401
    assert Task.find_by_name('test3')
    assert_select "errors"
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml', :story_id => 1
    assert_response :success
    assert_nil Task.find_by_name('test_task')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml', :story_id => 1
    assert_response 401
    assert Task.find_by_name('test_task')
    assert_select "errors"
  end

  # Test changing all the tasks status to done.
  def test_change_to_done_premium_team
    email_count = PLANIGLE_EMAIL_NOTIFIER.number_of_notifications
    sms_count = PLANIGLE_SMS_NOTIFIER.number_of_notifications
    login_as(individuals(:aaron))
    put :update, {:id => 1, :format => 'xml', :record => {:status_code => 3}, :story_id => 1}
    assert_equal email_count+3, PLANIGLE_EMAIL_NOTIFIER.number_of_notifications
    assert_equal sms_count+3, PLANIGLE_SMS_NOTIFIER.number_of_notifications
  end
    
  # Test successfully setting the owner.
  def test_moving_to_done_clears_effort
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:status_code =>3}, :story_id => 1
    assert_response :success
    assert_equal 0, tasks(:one).reload.effort
  end
    
  # Test successfully setting the owner.
  def test_moving_to_done_clears_effort_unless_set
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:status_code =>3, :effort =>1}, :story_id => 1
    assert_response :success
    assert_equal 1, tasks(:one).reload.effort
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner
    prepare_for_owner_test
    put :update, :id => 1, :record => {:status_code =>1}, :story_id => 1
    assert_response :success
    assert_equal 3, tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_set
    prepare_for_owner_test
    put :update, :id => 1, :record => {:status_code =>1, :individual_id =>2}, :story_id => 1
    assert_response :success
    assert_equal 2, tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_no_status
    prepare_for_owner_test
    put :update, :id => 1, :record => {:name => 'foo'}, :story_id => 1
    assert_response :success
    assert_nil tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_status_created
    prepare_for_owner_test
    put :update, :id => 1, :record => {:status_code =>0}, :story_id => 1
    assert_response :success
    assert_nil tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_owner_set
    prepare_for_owner_test(false)
    put :update, :id => 1, :record => {:status_code =>1}, :story_id => 1
    assert_response :success
    assert_equal 2, tasks(:one).reload.individual_id
  end
  
  def prepare_for_owner_test(clearOwner = true)
    task = tasks(:one)
    task.status_code = 0
    if clearOwner
      task.individual_id = nil
    end
    task.save(false)
    login_as(individuals(:ted))
  end
end