require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StoriesXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include StoriesTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :tasks

  # Re-raise errors caught by the controller.
  class StoriesController; def rescue_action(e) raise e end; end

  # Test getting a split story template without credentials.
  def test_split_get_unauthorized
    get '/stories/split/1', {}, accept_header
    assert_response 401
  end

  # Test getting a split story template without credentials.
  def test_split_get_unauthorized_flex
    get '/stories/split/1.xml', {}, flex_header
    assert_response 401
  end

  # Test getting a split story template successfully.
  def test_split_get_success
    get '/stories/split/1', {}, authorization_header
    assert_response 200
    assert_select 'story'
  end

  # Test getting a split story template successfully.
  def test_split_get_success_flex
    flex_login
    get '/stories/split/1.xml', {}, flex_header
    assert_response 200
    assert_select 'story'
  end

  # Test splitting a story without credentials.
  def test_split_put_unauthorized
    num = resource_count
    put '/stories/split/1', create_success_parameters, accept_header
    assert_response 401
    assert_equal num, resource_count    
  end

  # Test splitting a story without credentials.
  def test_split_put_unauthorized_flex
    num = resource_count
    put '/stories/split/1.xml', create_success_parameters, flex_header
    assert_response 401
    assert_equal num, resource_count    
  end

  # Test splitting a story successfully.
  def test_split_put_success
    num = resource_count
    put '/stories/split/1', create_success_parameters, authorization_header
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end

  # Test splitting a story successfully.
  def test_split_put_success_flex
    num = resource_count
    flex_login
    put '/stories/split/1.xml', create_success_parameters, flex_header
    assert_response 200
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    split = Story.find_by_name('foo')
    assert_equal 1, split.tasks.count
  end

  # Test splitting a story unsuccessfully.
  def test_split_put_failure
    num = resource_count
    put '/stories/split/1', create_failure_parameters, authorization_header
    assert_response 422
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test splitting a story unsuccessfully.
  def test_split_put_failure_flex
    num = resource_count
    flex_login
    put '/stories/split/1.xml', create_failure_parameters, flex_header
    assert_response 200
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    put '/stories/1', {:record => {:iteration_id => 2}}, authorization_header
    assert_response :success
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test successfully setting the iteration in Flex.
  def test_set_iteration_success_flex
    flex_login
    put '/stories/1.xml', {:record => {:iteration_id => 2}}, flex_header
    assert_response :success
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    put '/stories/1', {:record => {:iteration_id => 999}}, authorization_header
    assert_response :unprocessable_entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test unsuccessfully setting the iteration in Flex.
  def test_set_iteration_failure_flex
    flex_login
    put '/stories/1.xml', {:record => {:iteration_id => 999}}, flex_header
    assert_response :success
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    put '/stories/1', {:record => {:individual_id => 2}}, authorization_header
    assert_response :success
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test successfully setting the owner in Flex.
  def test_set_owner_success_flex
    flex_login
    put '/stories/1.xml', {:record => {:individual_id => 2}}, flex_header
    assert_response :success
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    put '/stories/1', {:record => {:individual_id => 999}}, authorization_header
    assert_response :unprocessable_entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_not_equal stories(:first).reload.individual_id, 999
  end
  
  # Test unsuccessfully setting the owner in Flex.
  def test_set_owner_failure_flex
    flex_login
    put '/stories/1.xml', {:record => {:individual_id => 999}}, flex_header
    assert_response :success
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_not_equal stories(:first).reload.individual_id, 999
  end

  # Test getting tasks for a story.
  def test_show_tasks
    get resource_url << '/1', {}, authorization_header
    assert_response :success
    assert_select resource_string
    assert_select 'story' do
      assert_select 'tasks' do
        assert_select 'task'
      end
    end
  end

  # Test getting tasks for a story in Flex.
  def test_show_tasks_flex
    flex_login
    get resource_url << '/1.xml', {}, flex_header
    assert_response :success
    assert_select resource_string
    assert_select 'story' do
      assert_select 'tasks' do
        assert_select 'task'
      end
    end
  end
end