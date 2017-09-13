require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../comments_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include CommentsTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :comments
  fixtures :stories
  fixtures :projects
  fixtures :individuals_projects

  # Test unsuccessfully changing the owner.
  def test_set_owner_success
    login_as(individuals(:aaron))
    put base_URL + '/1', params: {:record => {:individual_id => 3}}
    assert_response :success
    assert_not_equal comments(:one).reload.individual_id, 3
  end

  # Test getting comments (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Story.where(project_id: 1).inject(0){|sum, story| sum + story.comments.length})
  end
    
  # Test getting comments (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Story.where(project_id: 1).inject(0){|sum, story| sum + story.comments.length})
  end
    
  # Test getting comments (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Story.where(project_id: 1).inject(0){|sum, story| sum + story.comments.length})
  end
    
  # Test getting comments (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Story.where(project_id: 1).inject(0){|sum, story| sum + story.comments.length})
  end

  # Test getting comments (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a comment for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get '/planigle/api/stories/5/comments/3'
    assert_response 401
  end
    
  # Test creating comments (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating comments (based on role).
  def test_create_by_project_user
    create_by_role_successful(individuals(:user))
  end
    
  # Test creating comments (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a comment for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    post '/planigle/api/stories/5/comments', params: create_success_parameters
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
    
  # Test updating comments (based on role).
  def test_update_by_user
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating comments (based on role).
  def test_update_by_other_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating comments (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user )
    login_as(user)
    put base_URL + '/1', params: update_success_parameters
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put base_URL + '/1', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
    
  # Test deleting comments.
  def test_delete_by_user
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting comments.
  def test_delete_by_other_user
    delete_by_role_unsuccessful(individuals(:user))
  end
  
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Comment.where(message: 'test_comment').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Comment.where(message: 'test_comment').first
    assert json['error']
  end

  
  def prepare_for_owner_test(clearOwner = true)
    comment = comments(:one)
    comment.status_code = 0
    if clearOwner
      comment.individual_id = nil
    end
    comment.save( :validate=> false )
    login_as(individuals(:user))
  end
end