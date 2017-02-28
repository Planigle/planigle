require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "company_mailer"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :teams
  fixtures :companies

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    CompanyMailer.who_to_notify = 'test@testit.com'
  end

  # Test that the teams are included in the response.
  def test_response
    login_as(individuals(:aaron))
    get base_URL
    assert_response :success
    assert_equal 2, json.length
    assert_equal 2, json[0]['teams'].length
  end
  
  # Test getting projects (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Project.count)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:project_admin2), 1)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_admin_premium
    index_by_role(individuals(:aaron), 2)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user2), 1)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_user_premium
    index_by_role(individuals(:user), 2)
  end
    
  # Test getting projects (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:ro2), 1)
  end
    
  # Test getting projects (based on role).
  def test_index_by_read_only_user_premium
    index_by_role(individuals(:readonly), 2)
  end

  # Test getting projects (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing another project.
  def test_show_wrong_project
    login_as(individuals(:project_admin2))
    get base_URL + '/4'
    assert_response 401
  end

  # Test showing another project.
  def test_show_wrong_project_premium
    login_as(individuals(:aaron))
    get base_URL + '/3'
    assert_response :success
    assert json
  end

  # Test showing another project.
  def test_show_wrong_company
    login_as(individuals(:aaron))
    get base_URL + '/2'
    assert_response 401
  end
    
  # Test creating projects (based on role).
  def test_create_by_project_admin
    create_by_role_unsuccessful(individuals(:project_admin2))
  end
    
  # Test creating projects (based on role).
  def test_create_by_project_admin_premium
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating projects (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating projects (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
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
  
  # Create unsuccessfully for the wrong company.
  def create_wrong_company
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters
    params[:record].merge( :company_id => 2 )
    post base_URL, params: params
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end
    
  # Test updating projects (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating projects (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating projects (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating another project.
  def test_update_wrong_project
    login_as(individuals(:project_admin2))
    put base_URL + '/4', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
    
  # Test updating another project.
  def test_update_wrong_project_premium
    login_as(individuals(:aaron))
    put base_URL + '/3', params: update_success_parameters
    assert_response :success
    assert_update_succeeded
  end
    
  # Test updating another project.
  def test_update_wrong_company
    login_as(individuals(:aaron))
    put base_URL + '/2', params: update_success_parameters
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

  # Test deleting projects (based on role).
  def test_delete_by_project_admin
    delete_by_role_unsuccessful(individuals(:project_admin2))
  end

  # Test deleting projects (based on role).
  def test_delete_by_project_admin_premium
    delete_by_role_successful(individuals(:aaron), 3)
  end

  # Test deleting projects (based on role).
  def test_delete_by_project_admin_premium_own
    delete_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test deleting projects (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting projects (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user, id=1 )
    name = Project.find(id).name
    login_as(user)
    delete base_URL + '/' + id.to_s
    assert_response :success
    assert_nil Project.where(name: name).first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user, id=1 )
    name = Project.find(id).name
    login_as(user)
    delete  base_URL + '/' + id.to_s
    assert_response 401
    assert Project.where(name: name).first
    assert json['error']
  end
      
  # Delete unsuccessfully based on role.
  def delete_wrong_company
    login_as(individuals(:aaron))
    delete  base_URL + '/2'
    assert_response 401
    assert Project.where(name: 'Test').first
    assert json['error']
  end
end