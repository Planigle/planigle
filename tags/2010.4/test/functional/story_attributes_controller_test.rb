require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../story_attributes_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "story_attributes_controller"

# Re-raise errors caught by the controller.
class StoryAttributesController; def rescue_action(e) raise e end; end

class StoryAttributesControllerTest < ActionController::TestCase
  include ControllerResourceHelper
  include StoryAttributesTestHelper

  fixtures :systems
  fixtures :projects
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :story_attributes
  fixtures :story_attribute_values
  
  # Test index getting attribute values.
  def test_index_get_values
    login_as(individuals(:aaron))
    get :index, :format => 'xml', :project_id => 1
    assert_response :success
    assert_select "story-attributes" do
      assert_select "story-attribute", Project.find(1).story_attributes.length
    end
  end
  
  # Test show getting attribute values.
  def test_show_get_values
    login_as(individuals(:aaron))
    get :show, :format => 'xml', :id => 5
    assert_response :success
    assert_select "story-attribute" do
      assert_select "story-attribute-values" do
        assert_select "story-attribute-value", 3
      end
    end
  end
  
  # Test getting story attributes (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), StoryAttribute.count)
  end
    
  # Test getting story attributes (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Project.find(1).story_attributes.length)
  end
    
  # Test getting story_attributes (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Project.find(1).story_attributes.length)
  end
    
  # Test getting story attributes (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Project.find(1).story_attributes.length)
  end

  # Test getting story attributes (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml', :project_id => 1
    assert_response :success
    assert_select "story-attributes" do
      assert_select "story-attribute", count
    end
  end

  # Test showing a story attribute for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 4, :format => 'xml', :project_id => 2
    assert_response 401
  end
    
  # Test creating story attributes (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating story attributes (based on role).
  def test_create_by_project_user
    create_by_role_unsuccessful(individuals(:user))
  end
    
  # Test creating story attributes (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a story attribute for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters.merge( :format => 'xml' )
    params[:record] = params[:record].merge( :project_id => '2' )
    post :create, params
    assert_response 401
    assert_equal num, resource_count
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

  # Create successfully ignoring the is_custom field.
  def test_create_no_custom
    login_as(individuals(:admin2))
    num = resource_count
    params = create_success_parameters
    params[:record][:is_custom] = false
    post :create, params.merge( :format => 'xml' )
    assert_select "is-custom", "true"
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
  end    
    
  # Test updating story attributes (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
  
  # Test changing project.
  def test_update_project
    update_by_role_unsuccessful(individuals(:aaron), update_success_parameters.merge({:record => {:project_id => 3}}))
  end
    
  # Test updating story attributes (based on role).
  def test_update_by_project_user
    update_by_role_successful(individuals(:user))
  end
    
  # Test updating story attributes (based on role).
  def test_update_by_read_only_user
    update_by_role_successful(individuals(:readonly))
  end
    
  # Test updating a team for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    params = update_success_parameters.merge( :format => 'xml', :id => 4 )
    params[:record] = params[:record].merge( :project_id => '2' )
    put :update, params
    assert_response 401
    assert_change_failed
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = update_success_parameters )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(params)
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = update_success_parameters )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(params)
    assert_response 401
    assert_change_failed
    assert_select "errors"
  end
  
  # Update successfully without changing is_custom.
  def test_update_no_custom
    login_as(individuals(:admin2))
    params = update_success_parameters
    params[:record][:is_custom] = true
    put :update, {:id => 1, :format => 'xml'}.merge(params)
    assert_select 'is-custom', "true"
    assert_response :success
    assert_update_succeeded
  end
    
  # Test deleting story attributes (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting story attributes (based on role).
  def test_delete_by_project_user
    delete_by_role_unsuccessful(individuals(:user))
  end
    
  # Test deleting story attributes (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete :destroy, :id => 4, :format => 'xml'
    assert_response 401
    assert StoryAttribute.find_by_name('Test_String2')
    assert_select "errors"
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response :success
    assert_nil StoryAttribute.find_by_name('Test_String')
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete :destroy, :id => 1, :format => 'xml'
    assert_response 401
    assert Team.find_by_name('Test_team')
    assert_select "errors"
  end
end
