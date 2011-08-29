require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "projects_controller"
require "company_mailer"

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  include ControllerResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :teams

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    CompanyMailer.who_to_notify = 'test@testit.com'
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test that the teams are included in the xml.
  def test_xml
    login_as(individuals(:aaron))
    get :index, :format => 'xml'
    assert_response :success
    assert_select "projects" do
      assert_select "project", 2 do
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
    get :index, :format => 'xml'
    assert_response :success
    assert_select "projects" do
      assert_select "project", count
    end
  end

  # Test showing another project.
  def test_show_wrong_project
    login_as(individuals(:project_admin2))
    get :show, :id => 4, :format => 'xml'
    assert_response 401
  end

  # Test showing another project.
  def test_show_wrong_project_premium
    login_as(individuals(:aaron))
    get :show, :id => 3, :format => 'xml'
    assert_response :success
    assert_select "project"
  end

  # Test showing another project.
  def test_show_wrong_company
    login_as(individuals(:aaron))
    get :show, :id => 2, :format => 'xml'
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
  
  # Create unsuccessfully for the wrong company.
  def create_wrong_company
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record].merge( :company_id => 2 )
    post :create, params
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
    login_as(individuals(:project_admin2))
    put :update, {:id => 4, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
    
  # Test updating another project.
  def test_update_wrong_project_premium
    login_as(individuals(:aaron))
    put :update, {:id => 3, :format => 'xml'}.merge(update_success_parameters)
    assert_response :success
    assert_update_succeeded
  end
    
  # Test updating another project.
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
    delete :destroy, :id => id, :format => 'xml'
    assert_response :success
    assert_nil Project.find_by_name(name)
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user, id=1 )
    name = Project.find(id).name
    login_as(user)
    delete :destroy, :id => id, :format => 'xml'
    assert_response 401
    assert Project.find_by_name(name)
    assert_select "errors"
  end
      
  # Delete unsuccessfully based on role.
  def delete_wrong_company
    login_as(individuals(:aaron))
    delete :destroy, :id => 2, :format => 'xml'
    assert_response 401
    assert Project.find_by_name('Test')
    assert_select "errors"
  end
end
