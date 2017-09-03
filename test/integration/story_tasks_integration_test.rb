require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../tasks_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StoryTasksIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include TasksTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :tasks

  # Return the url to get the resource (ex., resources)
  def resource_url
    '/planigle/api/stories/1/tasks'
  end

  # Answer a string representing the type of object. Ex., Story.
  def object_type
    'Tasks'
  end

  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:name => 'foo', :story_id => 1}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:name => '', :story_id => 1}}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    stories(:first).reload()
    stories(:first).tasks.length
  end

  # Verify that the object was created.
  def assert_create_succeeded
    stories(:first).reload()
    assert stories(:first).tasks.find_by_name('foo')
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1/tasks/1', params: {:record => {:individual_id => 2}}, headers: authorization_header
    assert_response :success
    assert_equal tasks(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1/tasks/1', params: {:record => {:individual_id => 999}}, headers: authorization_header
    assert_response :unprocessable_entity
    assert json
    assert_not_equal tasks(:one).reload.individual_id, 999
  end
end