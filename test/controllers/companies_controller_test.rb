require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../companies_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "company_mailer"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include CompaniesTestHelper
  
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :teams

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    CompanyMailer.who_to_notify = 'test@testit.com'
  end

  # Test successfully signing up.
  def test_signup_success
    ActionMailer::Base.deliveries = []
    companies = resource_count
    individuals = Individual.count
    projects = Project.count
    params = create_success_parameters.merge( {:project => {:name => 'foo'}, :individual => {:login => 'foobar', :email => 'foo@sample.com', :last_name => 'bar', :role => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    post base_URL, params: params
    assert_response :success
    assert_equal companies + 1, resource_count
    assert_equal projects + 1, Project.count
    assert_equal individuals + 1, Individual.count
    assert_create_succeeded
    assert_equal 2, ActionMailer::Base.deliveries.length
    assert json['company']
    assert json['company']['filtered_projects'][0]
    assert json['individual']
  end

  # Test signing up unsuccessfully.
  def test_signup_failure
    ActionMailer::Base.deliveries = []
    num = resource_count
    individuals = Individual.count
    projects = Project.count
    post base_URL, params: create_success_parameters.merge( {:project => {:name => 'foo'}, :individual => {:login => '', :email => 'foo@sample.com', :last_name => 'bar', :role => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    assert_response 422
    assert_equal num, resource_count
    assert_equal projects, Project.count
    assert_equal individuals, Individual.count
    assert_change_failed
    assert_equal 0, ActionMailer::Base.deliveries.length
    assert json['errors']
  end

  # Test that the teams are included in the response.
  def test_response
    login_as(individuals(:aaron))
    get base_URL
    assert_response :success
    company = json[0]
    assert company['filtered_projects']
    project = company['filtered_projects'][0]
    assert project['teams']
    assert project['teams'][0]
  end
  
  # Test getting companies (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Company.count)
  end
    
  # Test getting companies (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), 1)
  end
    
  # Test getting companies (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), 1)
  end
    
  # Test getting companies (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), 1)
  end
    
  # Test getting companies (based on role).
  def index_by_role(user, count, params = {})
    login_as(user)
    get base_URL, params: params
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing another company.
  def test_show_wrong_company
    login_as(individuals(:aaron))
    get base_URL + '/2'
    assert_response 401
  end
    
  # Test creating companies (based on role).
  def test_create_by_project_admin
    create_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test creating companies (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating companies (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Create successfully based on role.
  def create_by_role_successful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response :success
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
    
  # Test updating companies (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating companies (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating companies (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating another company.
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

  # Test deleting companies (based on role).
  def test_delete_by_project_admin
    delete_by_role_unsuccessful(individuals(:aaron))
  end
    
  # Test deleting companies (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting companies (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Company.find_by_name('Test_company')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Company.find_by_name('Test_company')
    assert json['error']
  end
    
  # Test updating project by role.
  def test_update_premium_by_admin
    update_premium_by_role_successful( individuals(:quentin) )
  end
    
  # Test updating project by role.
  def test_update_premium_by_project_admin
    update_premium_by_role_unsuccessful( individuals(:aaron) )
  end
    
  # Test updating project by role.
  def test_update_premium_by_project_user
    update_premium_by_role_unsuccessful( individuals(:user) )
  end
    
  # Test updating project by role.
  def test_update_premium_by_readonly_user
    update_premium_by_role_unsuccessful( individuals(:readonly) )
  end

  # Update premium successfully based on role.
  def update_premium_by_role_successful( user )
    login_as(user)
    new_expire = Date.tomorrow
    put base_URL + '/1', params: {resource_symbol => {:premium_expiry => new_expire}}
    assert_response :success
    assert_equal new_expire, companies(:first).reload.premium_expiry

    put base_URL + '/1', params: {resource_symbol => {:premium_limit => 2}}
    assert_response :success
    assert_equal 2, companies(:first).reload.premium_limit
  end
  
  # Update premium unsuccessfully based on role.
  def update_premium_by_role_unsuccessful( user )
    login_as(user)
    old_expire = companies(:first).premium_expiry
    new_expire = Date.tomorrow
    put base_URL + '/1', params: {resource_symbol => {:premium_expiry => new_expire}}
    assert_response 401
    assert_equal old_expire, companies(:first).reload.premium_expiry
    assert json['error']

    old_limit = companies(:first).premium_limit
    put base_URL + '/1', params: {resource_symbol => {:premium_limit => 2}}
    assert_response 401
    assert_equal old_limit, companies(:first).reload.premium_limit
    assert json['error']
  end
end