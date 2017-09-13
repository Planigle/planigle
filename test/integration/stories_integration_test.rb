require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StoriesIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include StoriesTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :individuals_projects
  fixtures :tasks
  fixtures :story_attributes
  fixtures :story_values
  fixtures :teams
  fixtures :iterations
  fixtures :releases

  # Test splitting a story without credentials.
  def test_split_put_unauthorized
    num = resource_count
    post '/planigle/api/stories/split/1', params: create_success_parameters, headers: accept_header
    assert_response 401
    assert_equal num, resource_count    
  end

  # Test splitting a story successfully.
  def test_split_put_success
    login_as(individuals(:admin2))
    num = resource_count
    post '/planigle/api/stories/split/1', params: create_success_parameters, headers: authorization_header
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end

  # Test splitting a story unsuccessfully.
  def test_split_put_failure
    login_as(individuals(:admin2))
    num = resource_count
    post '/planigle/api/stories/split/1', params: create_failure_parameters, headers: authorization_header
    assert_response 422
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1', params: {:record => {:iteration_id => 2}}, headers: authorization_header
    assert_response :success
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1', params: {:record => {:iteration_id => 999}}, headers: authorization_header
    assert_response :unprocessable_entity
    assert json
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1', params: {:record => {:individual_id => 2}}, headers: authorization_header
    assert_response :success
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1', params: {:record => {:individual_id => 999}}, headers: authorization_header
    assert_response :unprocessable_entity
    assert json
    assert_not_equal stories(:first).reload.individual_id, 999
  end

  # Test getting tasks and values for a story.
  def test_show_tasks_and_values
    login_as(individuals(:admin2))
    get resource_url << '/1', params: {}, headers: authorization_header
    assert_response :success
    assert json
  end
end