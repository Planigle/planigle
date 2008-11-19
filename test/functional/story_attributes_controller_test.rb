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
  fixtures :story_attributes
    
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
    
  # Test updating story attributes (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating story attributes (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating story attributes (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
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
  def update_by_role_successful( user )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(update_success_parameters)
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put :update, {:id => 1, :format => 'xml'}.merge(update_success_parameters)
    assert_response 401
    assert_change_failed
    assert_select "errors"
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
