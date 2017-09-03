require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../teams_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include TeamsTestHelper

  fixtures :systems
  fixtures :projects
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :teams
    
  # Test getting teams (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Project.find(1).teams.length)
  end
    
  # Test getting teams (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Project.find(1).teams.length)
  end
    
  # Test getting teams (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Project.find(1).teams.length)
  end
    
  # Test getting teams (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Project.find(1).teams.length)
  end

  # Test getting teams (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a team for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get '/planigle/api/projects/2/teams/3'
    assert_response 401
  end
    
  # Test creating teams (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating teams (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating teams (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a team for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    post '/planigle/api/projects/2/teams', params: create_success_parameters
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
    
  # Test updating teams (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
  
  # Test changing project.
  def test_update_project
    update_by_role_unsuccessful(individuals(:aaron), update_success_parameters.merge({:record => {:project_id => 3}}))
  end
    
  # Test updating teams (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating teams (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a team for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put '/planigle/api/projects/2/teams/3', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = update_success_parameters )
    login_as(user)
    put base_URL + '/1', params: params
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = update_success_parameters )
    login_as(user)
    put base_URL + '/1', params: params
    assert_response 401
    assert_change_failed
    assert json['error']
  end
    
  # Test deleting teams (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting teams (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting teams (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete '/planigle/api/projects/2/teams/3'
    assert_response 401
    assert Team.where(name: 'test2').first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Team.where(name: 'Test_team').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Team.where(name: 'Test_team').first
    assert json['error']
  end
end
