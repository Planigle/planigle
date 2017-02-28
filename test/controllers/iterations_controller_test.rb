require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class IterationsControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include IterationsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :iterations
  fixtures :projects
  fixtures :individuals_projects

  # Test getting iterations (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), 0)
  end
    
  # Test getting iterations (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Iteration.where(project_id: 1).length)
  end
    
  # Test getting iterations (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Iteration.where(project_id: 1).length)
  end
    
  # Test getting iterations (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Iteration.where(project_id: 1).length)
  end
    
  # Test getting iterations (based on role).
  def index_by_role(user, count, params={})
    login_as(user)
    get base_URL, params: params
    assert_response :success
    assert_equal count ? count : 0, json.length
  end

  # Test showing an iteration for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/3'
    assert_response 401
  end
    
  # Test creating iterations (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating iterations (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating iterations (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating an iteration for another project.
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
    
  # Test updating iterations (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
  
  # Test changing project.
  def test_update_project
    update_by_role_unsuccessful(individuals(:aaron), update_success_parameters[resource_symbol].merge({:project_id => 3}))
  end
    
  # Test updating iterations (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating iterations (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating an iteration for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put base_URL + '/3', params: update_success_parameters
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
    
  # Test deleting iterations (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting iterations (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting iterations (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete base_URL + '/3'
    assert_response 401
    assert Iteration.where(name: 'third').first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Iteration.where(name: 'first').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Iteration.where(name: 'first').first
    assert json['error']
  end
end