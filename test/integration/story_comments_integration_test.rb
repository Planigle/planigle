require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../tasks_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StoryCommentsIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include CommentsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :comments

  # Return the url to get the resource (ex., resources)
  def resource_url
    '/planigle/api/stories/1/comments'
  end

  # Answer a string representing the type of object. Ex., Story.
  def object_type
    'Comments'
  end

  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:message => 'foo', :story_id => 1}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:message => '', :story_id => 1}}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    stories(:first).reload()
    stories(:first).comments.length
  end

  # Verify that the object was created.
  def assert_create_succeeded
    stories(:first).reload()
    assert stories(:first).comments.find_by_message('foo')
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1/comments/1', params: {:record => {:individual_id => 2}}, headers: authorization_header
    assert_response :success
    assert_equal comments(:one).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:admin2))
    put '/planigle/api/stories/1/comments/1', params: {:record => {:individual_id => 1}}, headers: authorization_header
    assert_response :success
    assert_not_equal comments(:one).reload.individual_id, 1
  end
end