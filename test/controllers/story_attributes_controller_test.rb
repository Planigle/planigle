require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../story_attributes_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class StoryAttributesControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include StoryAttributesTestHelper

  fixtures :systems
  fixtures :projects
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :teams
  
  # Test index getting attribute values.
  def test_index_get_values
    login_as(individuals(:aaron))
    get base_URL, params: {:project_id => 1}
    assert_response :success
    assert Project.find(1).story_attributes.length, json.length
  end
  
  # Test show getting attribute values.
  def test_show_get_values
    login_as(individuals(:aaron))
    get base_URL, params: {:id => 5}
    assert_response :success
    assert 3, json[0]['story-attribute-values']
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
    get base_URL, params: {:project_id => 1}
    assert_response :success
    assert count, json.length
  end

  # Test showing a story attribute for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/4', params: {:project_id => 2}
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
    params = create_success_parameters
    params[:record] = params[:record].merge( :project_id => '2' )
    post base_URL, params: params
    assert_response 401
    assert_equal num, resource_count
  end

  # Create successfully based on role.
  def create_by_role_successful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response 201
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

  # Create successfully ignoring the is_custom field.
  def test_create_no_custom
    login_as(individuals(:admin2))
    num = resource_count
    params = create_success_parameters
    params[:record][:is_custom] = false
    post base_URL, params: params
    assert true, json['is-custom']
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
    params = update_success_parameters
    params[:record] = params[:record].merge( :project_id => '2' )
    put base_URL + '/4', params: params
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = update_success_parameters )
    login_as(user)
    put base_URL + '/1', params: params
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = update_success_parameters )
    login_as(user)
    put base_URL + '/1', params: params
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully without changing is_custom.
  def test_update_no_custom
    login_as(individuals(:admin2))
    params = update_success_parameters
    params[:record][:is_custom] = true
    put base_URL + '/1', params: params
    assert true, json['is-custom']
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
    delete base_URL + '/4'
    assert_response 401
    assert StoryAttribute.where(name: 'Test_String2').first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil StoryAttribute.where(name: 'Test_String').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Team.where(name: 'Test_team').first
    assert json['error']
  end
end
