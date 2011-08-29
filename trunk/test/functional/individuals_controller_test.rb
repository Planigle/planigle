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
  
  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    @controller = IndividualsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test activating a user.
  def test_should_activate_user
    assert_nil Individual.authenticate('ted', 'testit')
    get :activate, :activation_code => individuals(:ted).activation_code
    assert_redirected_to 'http://test.host/'
    assert_equal individuals(:ted), Individual.authenticate('ted', 'testit')
  end

  # Test activation without a key.
  def test_should_not_activate_user_without_key
    get :activate
    assert_redirected_to 'http://test.host/'
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  # Test activation with a blank key.
  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_redirected_to 'http://test.host/'
  rescue ActionController::RoutingError
    # well played, sir
  end
    
  # Test getting individuals (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), 1)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:project_admin2), Individual.find(:all, :joins => :projects, :conditions => "projects.id = 2 and role != 0").length)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_admin_premium
    index_by_role(individuals(:aaron), Individual.find_all_by_company_id(1, :conditions => "role != 0").length)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user2), Individual.find(:all, :joins => :projects, :conditions => "projects.id = 2 and role != 0").length)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_project_user_premium
    index_by_role(individuals(:user), Individual.find_all_by_company_id(1, :conditions => "role != 0").length)
  end
    
  # Test getting individuals (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:ro2), Individual.find(:all, :joins => :projects, :conditions => "projects.id = 4 and role != 0").length)
  end

  # Test getting individuals (based on role).
  def test_index_by_read_only_user_premium
    index_by_role(individuals(:readonly), Individual.find_all_by_company_id(1, :conditions => "role != 0").length)
  end
    
  # Test getting companies (based on role).
  def test_index_no_changes
    index_by_role(individuals(:aaron), nil, {:date => (Time.now + 5).to_s})
  end
    
  # Test getting companies (based on role).
  def test_index_changes
    index_by_role(individuals(:aaron), Individual.find_all_by_company_id(1, :conditions => "role != 0").length, {:date => (Time.now - 5).to_s})
  end

  # Test getting individuals (based on role).
  def index_by_role(user, count, params={})
    login_as(user)
    get :index, {:format => 'xml'}.merge(params)
    assert_response :success
    assert_select "individuals" do
      assert_select "individual", count
    end
  end

  # Test showing an individual for another project.
  def test_show_wrong_project
    login_as(individuals(:project_admin2))
    get :show, :id => 10, :format => 'xml'
    assert_response 401
  end

  # Test showing an individual for another project.
  def test_show_wrong_project_premium
    login_as(individuals(:aaron))
    get :show, :id => 9, :format => 'xml'
    assert_response :success
    assert_select "individual"
  end

  # Test showing an individual for another company.
  def test_show_wrong_company
    login_as(individuals(:aaron))
    get :show, :id => 7, :format => 'xml'
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
    create_by_role_unsuccessful(individuals(:ro2))
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
    login_as(individuals(:project_admin2))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :project_id => '4' )
    post :create, params
    assert_response 401
    assert_equal num, resource_count
    assert_select 'errors'
  end

  # Test creating an individual for another project.
  def test_create_other_project_in_company
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :project_id => '3' )
    post :create, params
    assert_response 201
    assert_equal num + 1, resource_count
    assert Individual.find_by_login('foo')
    assert_equal ActionMailer::Base.deliveries.length, 1
  end

  # Test creating an individual for another company.
  def test_create_wrong_company
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :company_id =>'2', :project_id => '2' )
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
    assert_response 401
    assert_equal 0, individuals(:quentin).reload.role
  end
    
  # Test updating company by role.
  def test_update_company_by_admin
    update_company_by_role_successful( individuals(:quentin) )
  end
    
  # Test updating company by role.
  def test_update_company_by_project_admin
    update_company_by_role_unsuccessful( individuals(:aaron) )
  end
    
  # Test updating company by role.
  def test_update_company_by_project_user
    update_company_by_role_unsuccessful( individuals(:user) )
  end
    
  # Test updating company by role.
  def test_update_company_by_readonly_user
    update_company_by_role_unsuccessful( individuals(:readonly) )
  end
    
  # Test updating project by role.
  def test_update_project_by_admin
    update_project_by_role_successful( individuals(:quentin), {:project_id => 4, :team_id => nil}, 7 )
  end
    
  # Test updating project by role.
  def test_update_project_by_project_admin_same_company
    update_project_by_role_successful( individuals(:aaron) )
  end
    
  # Test updating project by role.
  def test_update_project_by_project_admin_different_company
    update_project_by_role_unsuccessful( individuals(:aaron), {:project_id => 4, :team_id => nil}, 7 )
  end
    
  # Test updating project by role.
  def test_update_project_by_project_user
    update_project_by_role_unsuccessful( individuals(:user) )
  end
    
  # Test updating project by role.
  def test_update_project_by_readonly_user
    update_project_by_role_unsuccessful( individuals(:readonly) )
  end

  # Test updating an individual for another project.
  def test_update_wrong_project
    login_as(individuals(:project_admin2))
    put :update, {:id => 10, :format => 'xml' }.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end

  # Test updating an individual for another project.
  def test_update_wrong_project_premium
    login_as(individuals(:aaron))
    put :update, {:id => 9, :format => 'xml' }.merge(update_success_parameters)
    assert_response :success
    assert_update_succeeded
  end

  # Test updating an individual for another company.
  def test_update_wrong_company
    login_as(individuals(:aaron))
    put :update, {:id => 7, :format => 'xml' }.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end

  # Test updating an individual with no company.
  def test_update_no_company
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
  
  # Update company successfully based on role.
  def update_company_by_role_successful( user, params = {:company_id => 2, :project_id => 2, :team_id => nil} )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response :success
    assert_equal 2, individuals(:ted).reload.project_id
  end
  
  # Update project successfully based on role.
  def update_project_by_role_successful( user, params = {:project_id => 3, :team_id => nil}, id=3 )
    login_as(user)
    put :update, :id => id, resource_symbol => params, :format => 'xml'
    assert_response :success
    assert_equal params[:project_id], Project.find(:first, :joins=>:individuals, :conditions=>['individuals.id=?',id]).id
  end
  
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response 401
    assert_change_failed
    assert_select "errors"
  end
  
  # Update company unsuccessfully based on role.
  def update_company_by_role_unsuccessful( user, params = {:company_id => 2, :project_id => 2, :team_id => nil} )
    login_as(user)
    put :update, :id => 3, resource_symbol => params, :format => 'xml'
    assert_response 401
    assert_equal 1, individuals(:ted).reload.project_id
    assert_select "errors"
  end
  
  # Update project unsuccessfully based on role.
  def update_project_by_role_unsuccessful( user, params = {:project_id => 3, :team_id => nil}, id=3 )
    orig_id = Individual.find(id).project_id
    login_as(user)
    put :update, :id => id, resource_symbol => params, :format => 'xml'
    assert_response 401
    assert_equal orig_id, Project.find(:first, :joins=>:individuals, :conditions=>['individuals.id=?',id]).id
    assert_select "errors"
  end
    
  # Can't change project id to a project that is already full.
  def update_project_full( user )
    login_as(user)
    project(:first).premium_limit = 1
    put :update, :id => 3, :project_id => 2, :format => 'xml'
    put :update, :id => 6, :project_id => 2, :format => 'xml'
    assert_equal 1, individuals(:admin2).reload.project_id
    assert_select "errors"
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
    login_as(individuals(:project_admin2))
    delete :destroy, :id => 10, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('quentin')
    assert_select "errors"
  end
  
  # Delete someone from a different project.
  def test_delete_wrong_project_premium
    login_as(individuals(:aaron))
    delete :destroy, :id => 9, :format => 'xml'
    assert_response :success
    assert_nil Individual.find_by_login('user3')
  end
  
  # Delete someone from a different company.
  def test_delete_wrong_company
    login_as(individuals(:aaron))
    delete :destroy, :id => 7, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('user2')
    assert_select "errors"
  end
  
  # Delete someone from no company.
  def test_delete_no_company
    login_as(individuals(:aaron))
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Individual.find_by_login('ro2')
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