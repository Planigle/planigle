require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../individuals_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "individuals_controller"
require "application"

# Re-raise errors caught by the controller.
class IndividualsController; def rescue_action(e) raise e end; end

class IndividualsControllerTest < Test::Unit::TestCase
  include ControllerResourceHelper
  include IndividualsTestHelper
  
  fixtures :individuals
  fixtures :projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = IndividualsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test activating a user.
  def test_should_activate_user
    assert_nil Individual.authenticate('ted', 'testit')
    get :activate, :activation_code => individuals(:ted).activation_code
    assert_redirected_to '/'
    assert_equal individuals(:ted), Individual.authenticate('ted', 'testit')
  end

  # Test activation without a key.
  def test_should_not_activate_user_without_key
    get :activate
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  # Test activation with a blank key.
  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # well played, sir
  end
    
  # Test getting individuals (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Individual.count)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Individual.find_all_by_project_id(1, :conditions => "role != 0").length)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), 1)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), 1)
  end

  # Test getting individuals (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml'
    assert_response :success
    assert_select "individuals" do
      assert_select "individual", count
    end
  end

  # Test showing an individual for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 1, :format => 'xml'
    assert_response 401
  end

  # Ensure project admin can't see admin in same project.
  def test_show_admin_by_project_admin
    login_as(individuals(:aaron))
    get :show, :id => 6, :format => 'xml'
    assert_response 401
  end
    
  # Test creating individuals (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating individuals (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating individuals (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test that a project admin can't create an admin.
  def test_project_admin_create_admin
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :role => 0 )
    post :create, params
    assert_response 401
    assert_equal num, resource_count
    assert_select 'errors'
  end

  # Test creating an individual for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :project_id => '2' )
    post :create, params
    assert_response 401
    assert_equal num, resource_count
    assert_select 'errors'
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
    
  # Test updating individuals (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating individuals (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating individuals (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating your own role.
  def test_update_role_self
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:role => 1}, :format => 'xml'
    assert_response :success
    assert_equal 0, individuals(:quentin).reload.role
  end
    
  # Test updating project by role.
  def test_update_project_by_admin
    update_project_by_role_successful( individuals(:quentin), false )
  end
    
  # Test updating project by role.
  def test_update_project_by_project_admin
    update_project_by_role_unsuccessful( individuals(:aaron), false )
  end
    
  # Test updating project by role.
  def test_update_project_by_project_user
    update_project_by_role_unsuccessful( individuals(:user), true )
  end
    
  # Test updating project by role.
  def test_update_project_by_readonly_user
    update_project_by_role_unsuccessful( individuals(:readonly), true )
  end

  # Test updating an individual for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put :update, {:id => 1, :format => 'xml' }.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end

  # Test to ensure that a project admin can't modify an admin (even if in the same project).
  def test_update_admin_by_project_admin
    login_as(individuals(:aaron))
    put :update, {:id => 6, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end

  # Test to ensure that a project admin can't modify a user to become an admin (even if in the same project).
  def test_update_to_admin_by_project_admin
    login_as(individuals(:aaron))
    params = {:id => 2, :format => 'xml'}.merge(update_success_parameters)
    params[:record] = params[:record].merge(:role => 0)
    put :update, params
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response :success
    assert_update_succeeded
  end
  
  # Update project successfully based on role.
  def update_project_by_role_successful( user, unauthorized, params = {:project_id => 2} )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response :success
    assert_equal 2, individuals(:ted).reload.project_id
  end
  
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response 401
    assert_change_failed
    assert_select "errors"
  end
  
  # Update project unsuccessfully based on role.
  def update_project_by_role_unsuccessful( user, unauthorized, params = {:project_id => 2} )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response (unauthorized ? 401 : :success)
    assert_equal 1, individuals(:ted).reload.project_id
    if unauthorized
      assert_select "errors"
    end
  end
    
  # Test deleting individuals (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting individuals (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting individuals (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete someone from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('quentin')
    assert_select "errors"
  end

  # Test to ensure that a project admin can't delete an admin (even if in the same project).
  def test_delete_admin_by_project_admin
    login_as(individuals(:aaron))
    delete :destroy, :id => 6, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('admin2')
    assert_select "errors"
  end
    
  # Test deleting yourself.
  def test_delete_self
    login_as(individuals(:quentin))
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('quentin')
    assert_select "errors"
  end
  
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete :destroy, :id => 3, :format => 'xml'
    assert_response :success
    assert_nil Individual.find_by_login('ted')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 3, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('ted')
    assert_select "errors"
  end
end