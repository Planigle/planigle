require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "stories_controller"
require "bigdecimal"

# Re-raise errors caught by the controller.
class StoriesController; def rescue_action(e) raise e end; end

class StoriesControllerTest < ActionController::TestCase
  include ControllerResourceHelper
  include StoriesTestHelper

  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :tasks
  fixtures :surveys
  fixtures :survey_mappings

  # Test successfully getting a partial list (by iteration)
  def test_list_partial
    login_as(individuals(:quentin))
    xhr :get, :index, {:iteration_id => 1}
    assert_response :success
    assert_template "list"
  end

  # Test getting a split story template without credentials.
  def test_split_get_unauthorized
    get :split, :id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test getting a split story template successfully.
  def test_split_get_success
    login_as(individuals(:quentin))
    get :split, :id => 1
    assert_response :success
    assert_not_nil assigns(resource_symbol)
    assert assigns(resource_symbol).valid?
  end

  # Test splitting a story without credentials.
  def test_split_put_unauthorized
    num = resource_count
    put :split, :id => 1, resource_symbol => (create_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert_equal num, resource_count    
  end

  # Test splitting a story successfully.
  def test_split_put_success
    num = resource_count
    login_as(individuals(:quentin))
    put :split, :id => 1, resource_symbol => (create_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end

  # Test splitting a story unsuccessfully.
  def test_split_put_failure
    num = resource_count
    login_as(individuals(:quentin))
    put :split, :id => 1, resource_symbol => (create_failure_parameters[resource_symbol]) # hack to get around compiler issue
    assert_response :success
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:iteration_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:iteration_id => 999}
    assert_response :success
    assert_template 'update_form'
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 2}
    assert_redirected_to :action => :index
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, :record => {:individual_id => 999}
    assert_response :success
    assert_template 'update_form'
    assert_not_equal stories(:first).reload.individual_id, 999
  end
    
  # Test that changing from accepted to created or in progress recalculates surveys.
  def test_status_code_change
    assert_equal 2, stories(:first).user_priority
    login_as(individuals(:quentin))

    put :update, :id => 2, :record => {:status_code => 0}
  
    # Rounded to 1000th place to eliminate trivial differences
    assert_equal BigDecimal("1.5"), stories(:first).reload.user_priority
    
    put :update, :id => 2, :record => {:status_code => 1}
    assert_equal BigDecimal("1.5"), stories(:first).reload.user_priority
  end

  # Test getting stories (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Story.count)
  end
    
  # Test getting stories (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Story.find_all_by_project_id(1).length)
  end
    
  # Test getting stories (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Story.find_all_by_project_id(1).length)
  end
    
  # Test getting stories (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Story.find_all_by_project_id(1).length)
  end

  # Test getting stories (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml'
    assert_response :success
    assert_select "stories" do
      assert_select "story", count
    end
  end

  # Test showing a story for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 5, :format => 'xml'
    assert_response 401
  end
    
  # Test creating stories (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating stories (based on role).
  def test_create_by_project_user
    create_by_role_successful(individuals(:user))
  end
    
  # Test creating stories (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a story for another project.
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
    
  # Test splitting stories (based on role).
  def test_split_by_project_admin
    split_by_role_successful(individuals(:aaron))
  end
    
  # Test splitting stories (based on role).
  def test_split_by_project_user
    split_by_role_successful(individuals(:user))
  end
    
  # Test creating stories (based on role).
  def test_split_by_read_only_user
    split_by_role_unsuccessful(individuals(:readonly))
  end

  # Test splitting a story for another project.
  def test_split_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :id => 1, :format => 'xml' )
    params[:record] = params[:record].merge( :project_id => '2' )
    post :split, params
    assert_response 401
    assert_equal num, resource_count
    assert_select 'errors'
  end

  # Split successfully based on role.
  def split_by_role_successful( user )
    login_as(user)
    num = resource_count
    put :split, create_success_parameters.merge( :id => 1, :format => 'xml' )
    assert_response :success
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end    
  
  # Split unsuccessfully based on role.
  def split_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    put :split, create_success_parameters.merge( :id => 1, :format => 'xml' )
    assert_response 401
    assert_equal num, resource_count
    assert_select "errors"
  end

  # Test updating stories (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating stories (based on role).
  def test_update_by_project_user
    update_by_role_successful(individuals(:user))
  end
    
  # Test updating stories (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a story for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put :update, {:id => 5, :format => 'xml'}.merge(update_success_parameters)
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
    
  # Test deleting stories (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting stories (based on role).
  def test_delete_by_project_user
    delete_by_role_successful(individuals(:user))
  end
    
  # Test deleting stories (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete :destroy, :id => 5, :format => 'xml'
    assert_response 401
    assert Story.find_by_name('test5')
    assert_select "errors"
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response :success
    assert_nil Story.find_by_name('test1')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Story.find_by_name('test')
    assert_select "errors"
  end
end