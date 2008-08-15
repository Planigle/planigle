require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "projects_controller"

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
  include ControllerResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :teams

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.admin_email = 'testxyz@testxyz.com'
    IndividualMailer.site = 'www.testxyz.com'
    super
  end

  # Test successfully signing up.
  def test_signup_success
    ActionMailer::Base.deliveries = []
    num = resource_count
    individuals = Individual.count
    post :create, create_success_parameters.merge( {:individual => {:login => 'foo', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :project_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    assert_equal num + 1, resource_count
    assert_equal individuals + 1, Individual.count
    assert_create_succeeded
    assert_equal 2, ActionMailer::Base.deliveries.length
    assert_select "project"
    assert_select "individual"
  end

  # Test signing up unsuccessfully.
  def test_signup_failure
    ActionMailer::Base.deliveries = []
    num = resource_count
    individuals = Individual.count
    post :create, create_success_parameters.merge( {:individual => {:login => '', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :project_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}} )
    assert_response :success
    assert_equal num, resource_count
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
    assert_select "projects" do
      assert_select "project", 1 do
        assert_select "teams" do
          assert_select "team", 2
        end
      end
    end
  end
  
  # Test getting projects (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Project.count)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), 1)
  end
    
  # Test getting projects (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), 1)
  end
    
  # Test getting projects (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), 1)
  end

  # Test getting projects (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml'
    assert_response :success
    assert_select "projects" do
      assert_select "project", count
    end
  end

  # Test showing another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 2, :format => 'xml'
    assert_response 401
  end
    
  # Test creating projects (based on role).
  def test_create_by_project_admin
    create_by_role_unsuccessful(individuals(:aaron))
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
    
  # Test deleting projects (based on role).
  def test_delete_by_project_admin
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
  def delete_by_role_successful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response :success
    assert_nil Project.find_by_name('Test')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Project.find_by_name('Test')
    assert_select "errors"
  end
end
