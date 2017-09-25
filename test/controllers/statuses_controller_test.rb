require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../statuses_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class StatusesControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include StatusesTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :statuses
    
  # Test getting statuses (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), 0)
  end
    
  # Test getting statuses (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Status.where(project_id: 1).length)
  end
    
  # Test getting statuses (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Status.where(project_id: 1).length)
  end
    
  # Test getting statuses (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Status.where(project_id: 1).length)
  end

  # Test getting statuses (based on role).
  def index_by_role(user, count, params={})
    login_as(user)
    get base_URL, params: params
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a status for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/5'
    assert_response 401
  end
    
  # Test creating statuses (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating statuses (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating statuses (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a status for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters
    params[:record] = params[:record].merge( :project_id => '2' )
    post base_URL, params: params
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
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
    
  # Test updating statuses (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
  
  # Test changing project.
  def test_update_project
    update_by_role_unsuccessful(individuals(:aaron), update_success_parameters[resource_symbol].merge({:project_id => 3}))
  end
    
  # Test updating statuses (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating statuses (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a status for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put base_URL + '/5', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put base_URL + '/1', params: {resource_symbol => params}
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put base_URL + '/1', params: {resource_symbol => params}
    assert_response 401
    assert_change_failed
    assert json['error']
  end
    
  # Test deleting statuses (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting statuses (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting statuses (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete base_URL + '/5'
    assert_response 401
    assert Status.where(id: 5).first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/17'
    assert_response :success
    assert_nil Status.where(id: 17).first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/17'
    assert_response 401
    assert Status.where(id: 1).first
    assert json['error']
  end

  # Test deleting an resource without credentials.
  def test_destroy_unauthorized
    delete base_URL + '/17', params: context
    assert_response 401
    assert_delete_failed
  end
    
  # Test successfully deleting a resource.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete base_URL + '/17', params: context
    assert_response :success
    assert_delete_succeeded
  end
end