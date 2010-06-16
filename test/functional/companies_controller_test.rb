require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../companies_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "companies_controller"
require "project_mailer"

# Re-raise errors caught by the controller.
class CompaniesController; def rescue_action(e) raise e end; end

class CompaniesControllerTest < Test::Unit::TestCase
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
    ProjectMailer.who_to_notify = 'test@testit.com'
    @controller = CompaniesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test successfully signing up.
  def test_signup_success
    ActionMailer::Base.deliveries = []
    num = resource_count
    individuals = Individual.count
    projects = Project.count
    post :create, create_success_parameters.merge( {:project => {:name => 'foo'}, :individual => {:login => 'foo', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :company_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    assert_equal num + 1, resource_count
    assert_equal projects + 1, Project.count
    assert_equal individuals + 1, Individual.count
    assert_create_succeeded
    assert_equal 2, ActionMailer::Base.deliveries.length
    assert_select "company"
      assert_select "project"
    assert_select "individual"
  end

  # Test signing up unsuccessfully.
  def test_signup_failure
    ActionMailer::Base.deliveries = []
    num = resource_count
    individuals = Individual.count
    projects = Project.count
    post :create, create_success_parameters.merge( {:project => {:name => 'foo'}, :individual => {:login => '', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :company_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    assert_response :success
    assert_equal num, resource_count
    assert_equal projects, Project.count
    assert_equal individuals, Individual.count
    assert_change_failed
    assert_equal 0, ActionMailer::Base.deliveries.length
    assert_select "errors"
  end

  # Test that the teams are included in the xml.
  def test_xml
    login_as(individuals(:aaron))
    get :index, :format => 'xml'
    assert_response :success
    assert_select "companies" do
      assert_select "company", 1 do
        assert_select "projects" do
        assert_select "project", 2 do
            assert_select "teams" do
              assert_select "team", 2
            end
          end
        end
      end
    end
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
  def test_index_no_changes
    index_by_role(individuals(:aaron), nil, {:date => (Time.now + 5).to_s})
  end
    
  # Test getting companies (based on role).
  def test_index_changes
    index_by_role(individuals(:aaron), 1, {:date => (Time.now - 5).to_s})
  end

  # Test getting companies (based on role).
  def index_by_role(user, count, params = {})
    login_as(user)
    get :index, {:format => 'xml'}.merge(params)
    assert_response :success
    assert_select "companies" do
      assert_select "company", count
    end
  end

  # Test showing another company.
  def test_show_wrong_company
    login_as(individuals(:aaron))
    get :show, :id => 2, :format => 'xml'
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
    post :create, create_success_parameters.merge( :format => 'xml' )
    assert_response :success
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
    put :update, {:id => 2, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put :update, :id => 1, resource_symbol => params, :format => 'xml'
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put :update, :id => 1, resource_symbol => params, :format => 'xml'
    assert_response 401
    assert_change_failed
    assert_select "errors"
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
    delete :destroy, :id => 1, :format => 'xml'
    assert_response :success
    assert_nil Company.find_by_name('Test_company')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Company.find_by_name('Test_company')
    assert_select "errors"
  end
end
