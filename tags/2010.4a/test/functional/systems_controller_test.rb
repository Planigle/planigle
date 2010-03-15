require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../systems_test_helper"
require "systems_controller"

# Re-raise errors caught by the controller.
class SystemsController; def rescue_action(e) raise e end; end

class SystemsControllerTest < ActionController::TestCase
  include SystemsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :release_totals
  fixtures :iteration_totals
  fixtures :iteration_velocities
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_values

  # Test summarizing data.
  def test_summarize
    get :summarize
  end

  # Test getting report data.
  def test_report
    login_as(individuals(:admin2))
    get :report
    assert_select "release-totals" do
      assert_select "release-total", 2
    end
    assert_select "release-breakdowns" do
      assert_select "category-total", 16
    end
    assert_select "iteration-totals" do
      assert_select "iteration-total", 2
    end
    assert_select "iteration-breakdowns" do
      assert_select "category-total", 16
    end
    assert_select "iteration-velocities" do
      assert_select "iteration-velocity", 2
    end
  end

  def test_report_admin
    i = individuals(:quentin)
    i.selected_project_id = 1
    i.save(false)
    login_as(individuals(:quentin))
    get :report
    assert_select "release-totals" do
      assert_select "release-total", 2
    end
    assert_select "iteration-totals" do
      assert_select "iteration-total", 2
    end
    assert_select "iteration-velocities" do
      assert_select "iteration-velocity", 2
    end
  end
    
  # Test creating a new resource without credentials.
  def test_create_unauthorized
    num = resource_count
    post :create, create_failure_parameters
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_equal num, resource_count
    assert_change_failed
  end

  # Test creating a new resource unsuccessfully.
  def test_create_failure
    login_as(individuals(:quentin))
    num = resource_count
    post :create, create_failure_parameters
    assert_response :success
    assert_equal num, resource_count
    assert_change_failed
  end

  # Test updating an resource without credentials.
  def test_update_unauthorized
    put :update, {:id => 1}.merge(update_success_parameters)
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_change_failed
  end

  # Test succcessfully updating an resource.
  def test_update_success
    login_as(individuals(:quentin))
    put :update, {:id => 1}.merge(update_success_parameters)
    assert_response :success
    assert_update_succeeded
  end

  # Test updating an resource where the update fails.
  def test_update_failure
    login_as(individuals(:quentin))
    put :update, {:id => 1}.merge(update_failure_parameters)
    assert_response :success
    assert_change_failed
  end

  # Test deleting an resource without credentials.
  def test_destroy_unauthorized
    delete :destroy, {:id => 2}.merge(context)
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_equal 1, System.count
  end
    
  # Test unsuccessfully deleting a resource.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete :destroy, {:id => 1}.merge(context)
    assert_response :success
    assert_equal 1, System.count
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
    post :create, create_failure_parameters.merge( :format => 'xml' )
    assert_response 401
    assert_equal num, resource_count
    assert_select "errors"
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
    
  # Test updating another system.
  def test_update_wrong_system
    login_as(individuals(:aaron))
    put :update, {:id => 2, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[:record]) )
    login_as(user)
    put :update, :id => 1, :record => params, :format => 'xml'
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[:record]) )
    login_as(user)
    put :update, :id => 1, :record => params, :format => 'xml'
    assert_response 401
    assert_change_failed
    assert_select "errors"
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
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert_equal 1, System.count
    assert_select "errors"
  end
end