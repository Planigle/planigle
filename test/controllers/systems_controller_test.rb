require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../systems_test_helper"

class SystemsControllerTest < ActionDispatch::IntegrationTest
  base_URL = '/system'
  
  include SystemsTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :teams
  fixtures :projects
  fixtures :individuals_projects
  fixtures :release_totals
  fixtures :iteration_totals
  fixtures :iteration_story_totals
  fixtures :iteration_velocities
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_values
  fixtures :tasks
  fixtures :criteria

  # Test summarizing data.
  def test_summarize
    get '/planigle/api/summarize'
  end

  # Test getting report data.
  def test_iteration_totals
    login_as(individuals(:admin2))
    get '/planigle/api/report_iteration_totals', params: {iteration_id: 1}
    assert_response :success
    assert json
  end

  # Test getting report data.
  def test_iteration_totals_unauthorized
    get '/planigle/api/report_iteration_totals', params: {iteration_id: 1}
    assert_response 401
    assert json['error']
  end

  # Test getting report data.
  def test_release_totals
    login_as(individuals(:admin2))
    get '/planigle/api/report_release_totals', params: {release_id: 1}
    assert_response :success
    assert json
  end

  # Test getting report data.
  def test_release_totals_unauthorized
    get '/planigle/api/report_release_totals', params: {release_id: 1}
    assert_response 401
    assert json['error']
  end

  # Test getting report data.
  def test_team_totals
    login_as(individuals(:admin2))
    get '/planigle/api/report_team_totals'
    assert_response :success
    assert json
  end

  # Test getting report data.
  def test_team_totals_unauthorized
    get '/planigle/api/report_team_totals'
    assert_response 401
    assert json['error']
  end

  # Test getting report data.
  def test_upcoming_iterations
    login_as(individuals(:admin2))
    get '/planigle/api/report_upcoming_iterations'
    assert_response :success
    assert json
  end

  # Test getting report data.
  def test_upcoming_iterations_unauthorized
    get '/planigle/api/report_upcoming_iterations'
    assert_response 401
    assert json['error']
  end

  # Test getting report data.
  def test_iteration_metrics
    login_as(individuals(:admin2))
    get '/planigle/api/report_iteration_metrics'
    assert_response :success
    assert json
  end

  # Test getting report data.
  def test_iteration_metrics_unauthorized
    get '/planigle/api/report_iteration_metrics'
    assert_response 401
    assert json['error']
  end
    
  # Test creating a new resource without credentials.
  def test_create_unauthorized
    num = resource_count
    post base_URL, params: create_failure_parameters
    assert_response 401
    assert_equal num, resource_count
    assert_change_failed
  end

  # Test creating a new resource unsuccessfully.
  def test_create_failure
    login_as(individuals(:quentin))
    num = resource_count
    post base_URL, params: create_failure_parameters
    assert_equal num, resource_count
    assert_change_failed
    assert json['error']
  end

  # Test updating an resource without credentials.
  def test_update_unauthorized
    put base_URL, params: update_success_parameters
    assert_response 401
    assert_change_failed
  end

  # Test successfully updating an resource.
  def test_update_success
    login_as(individuals(:quentin))
    put base_URL, params: update_success_parameters
    assert_response :success
    assert_update_succeeded
  end

  # Test deleting an resource without credentials.
  def test_destroy_unauthorized
    delete base_URL, params: context
    assert_response 401
    assert_equal 1, System.count
    assert json['error']
  end
    
  # Test unsuccessfully deleting a resource.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete base_URL, params: context
    assert_response 401
    assert_equal 1, System.count
    assert json['error']
  end
    
  # Test creating systems (based on role).
  def test_create_by_system_admin
    create_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test creating systems (based on role).
  def test_create_by_system_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating systems (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Create unsuccessfully based on role.
  def create_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_failure_parameters
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end
    
  # Test updating systems (based on role).
  def test_update_by_project_admin
    update_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test updating systems (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating systems (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[:record]) )
    login_as(user)
    put base_URL, params: {:record => params}
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[:record]) )
    login_as(user)
    put base_URL, params: {:record => params}
    assert_response 401
    assert_change_failed
    assert json['error']
  end
    
  # Test deleting systems (based on role).
  def test_delete_by_project_admin
    delete_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test deleting systems (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting systems (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
      
  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL
    assert_response 401
    assert_equal 1, System.count
    assert json['error']
  end
    
private

  def json
    JSON.parse(response.body)
  end
end