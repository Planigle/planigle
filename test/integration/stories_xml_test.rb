require "#{File.dirname(__FILE__)}/../test_helper"

class StoriesXmlTest < ActionController::IntegrationTest
  fixtures :individuals
  fixtures :stories

  # Re-raise errors caught by the controller.
  class StoriesController; def rescue_action(e) raise e end; end

  # Test the get /stories request without credentials.
  def test_index_unauthorized
    get '/stories', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /stories request.
  def test_index_success
    get '/stories', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'stories' do
      assert_select 'story', :count => 2    
    end
  end

  # Test the post /stories request.
  def test_create_unauthorized
    num_stories = Story.count
    post '/stories', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_equal num_stories, Story.count
  end

  # Test a successful post /stories request.
  def test_create_success
    num_stories = Story.count
    post '/stories', {:story => {:name => 'test'}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 201 # Created
    assert_select 'story'
    assert Story.find_by_name('test')
    assert_equal num_stories+1, Story.count
  end

  # Test a failed post /stories request.
  def test_create_failure
    num_stories = Story.count
    post '/stories', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Story.find_by_name(nil)
    assert_equal num_stories, Story.count
  end

  # Test the get /stories/id request without credentials.
  def test_show_unauthorized
    get '/stories/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /stories/id request.
  def test_show_success
    get '/stories/1', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'story'
  end
  
  # Test the put /stories/id request without credentials.
  def test_update_unauthorized
    put '/stories/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful put /stories/id request.
  def test_update_success
    put '/stories/1', {:story => {:name => 'foo'}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert Story.find_by_name('foo')
  end

  # Test a failed put /stories/id request.
  def test_update_failure
    put '/stories/1', {:story => {:name => ''}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Story.find_by_name('')
  end
  
  # Test the delete /stories/id request without credentials.
  def test_destroy_unauthorized
    delete '/stories/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_not_nil Story.find_by_name('test')
  end

  # Test a successful delete /stories/id request .
  def test_destroy_success
    delete '/stories/1', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert_nil Story.find_by_name('test')
  end

  # Test a failed delete /stories/id request.
  def test_destroy_failure
    delete '/stories/999', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 404 # Does not exist
  end
end