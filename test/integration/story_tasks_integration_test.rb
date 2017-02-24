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

  # Re-raise errors caught by the controller.
  class TasksController; def rescue_action(e) raise e end; end

  # Return the url to get the resource (ex., resources)
  def resource_url
    '/stories/1/tasks'
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
    put '/stories/1/tasks/1', params: {:record => {:individual_id => 2}}, headers: authorization_header
    assert_response :success
    assert_equal tasks(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    put '/stories/1/tasks/1', params: {:record => {:individual_id => 999}}, headers: authorization_header
    assert_response :unprocessable_entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_not_equal tasks(:one).reload.individual_id, 999
  end
end