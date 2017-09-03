require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../tasks_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include TasksTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :tasks
  fixtures :stories
  fixtures :projects
  fixtures :individuals_projects
    
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:individual_id => 2}}
    assert_response :success
    assert_equal tasks(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:individual_id => 999}}
    assert_response 422
    assert_not_equal tasks(:one).reload.individual_id, 999
  end

  # Test getting tasks (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Story.where(project_id: 1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Story.where(project_id: 1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Story.where(project_id: 1).inject(0){|sum, story| sum + story.tasks.length})
  end
    
  # Test getting tasks (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Story.where(project_id: 1).inject(0){|sum, story| sum + story.tasks.length})
  end

  # Test getting tasks (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a task for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get '/planigle/api/stories/5/tasks/3'
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
    post '/planigle/api/stories/5/tasks', params: create_success_parameters
    assert_response 401
    assert_equal num, resource_count
  end

  # Create successfully based on role.
  def create_by_role_successful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
  end    
  
  # Create unsuccessfully based on role.
  def create_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
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
    put '/planigle/api/stories/5/tasks/3', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user )
    login_as(user)
    put base_URL + '/1', params: update_success_parameters
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put base_URL + '/1', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
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
    delete '/planigle/api/stories/5/tasks/3'
    assert_response 401
    assert Task.where(name: 'test3').first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Task.where(name: 'test_task').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Task.where(name: 'test_task').first
    assert json['error']
  end

  # Test changing all the tasks status to done.
  def test_change_to_done_premium_team
    email_count = PLANIGLE_EMAIL_NOTIFIER.number_of_notifications
    sms_count = PLANIGLE_SMS_NOTIFIER.number_of_notifications
    login_as(individuals(:aaron))
    put base_URL + '/1', params: {:record => {:status_code => 3}}
    assert_equal email_count+2, PLANIGLE_EMAIL_NOTIFIER.number_of_notifications
    assert_equal sms_count+2, PLANIGLE_SMS_NOTIFIER.number_of_notifications
  end
    
  # Test successfully setting the owner.
  def test_moving_to_done_clears_effort
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:status_code =>3}}
    assert_response :success
    assert_equal 0, tasks(:one).reload.effort
  end
    
  # Test successfully setting the owner.
  def test_moving_to_done_clears_effort_unless_set
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:status_code =>3, :effort =>1}}
    assert_response :success
    assert_equal 1, tasks(:one).reload.effort
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner
    prepare_for_owner_test
    put base_URL + '/1', params: {:record => {:status_code =>1}}
    assert_response :success
    assert_equal 4, tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_set
    prepare_for_owner_test
    put base_URL + '/1', params: {:record => {:status_code =>1, :individual_id =>2}}
    assert_response :success
    assert_equal 2, tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_no_status
    prepare_for_owner_test
    put base_URL + '/1', params: {:record => {:name => 'foo'}}
    assert_response :success
    assert_nil tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_status_created
    prepare_for_owner_test
    put base_URL + '/1', params: {:record => {:status_code =>0}}
    assert_response :success
    assert_nil tasks(:one).reload.individual_id
  end
    
  # Test successfully setting the owner.
  def test_moving_to_in_progress_assigns_owner_unless_owner_set
    prepare_for_owner_test(false)
    put base_URL + '/1', params: {:record => {:status_code =>1}}
    assert_response :success
    assert_equal 2, tasks(:one).reload.individual_id
  end
  
  def prepare_for_owner_test(clearOwner = true)
    task = tasks(:one)
    task.status_code = 0
    if clearOwner
      task.individual_id = nil
    end
    task.save( :validate=> false )
    login_as(individuals(:user))
  end
end