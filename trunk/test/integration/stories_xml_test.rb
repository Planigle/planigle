require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class StoriesXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include StoriesTestHelper

  fixtures :individuals
  fixtures :stories
  fixtures :tasks

  # Re-raise errors caught by the controller.
  class StoriesController; def rescue_action(e) raise e end; end

  # Test changing the sort order without credentials.
  def test_sort_success_unauthorized
    put '/stories/sort_stories', {:stories => [1, 2, 3]}, accept_header
    assert_response 401 # Unauthorized
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test changing the sort order without credentials from Flex.
  def test_sort_success_unauthorized_flex
    put '/stories/sort_stories.xml', {:stories => [1, 2, 3]}, flex_header
    assert_response 401 # Unauthorized
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test successfully changing the sort order.
  def test_sort_success
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    put '/stories/sort_stories', {:stories => [1, 2, 3]}, authorization_header
    assert_response :success
    assert_select 'stories' do
      assert_select 'story', :count => 3
    end
    assert_equal [1, 2, 3], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test successfully changing the sort order from Flex.
  def test_sort_success_flex
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    flex_login
    put '/stories/sort_stories.xml', {:stories => [1, 2, 3]}, flex_header
    assert_response :success
    assert_select 'stories' do
      assert_select 'story', :count => 3
    end
    assert_equal [1, 2, 3], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test failure to change the sort order.
  def test_sort_failure
    put '/stories/sort_stories', {:stories => [999, 2, 3]}, authorization_header
    assert_response 404
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test failure to change the sort order from Flex.
  def test_sort_failure_flex
    flex_login
    put '/stories/sort_stories.xml', {:stories => [999, 2, 3]}, flex_header
    assert_response 404
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
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