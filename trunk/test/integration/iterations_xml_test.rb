require "#{File.dirname(__FILE__)}/../test_helper"

class IterationsXmlTest < ActionController::IntegrationTest
  fixtures :individuals
  fixtures :iterations

  # Re-raise errors caught by the controller.
  class IterationsController; def rescue_action(e) raise e end; end

  # Test the get /iterations request without credentials.
  def test_index_unauthorized
    get '/iterations', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /iterations request.
  def test_index_success
    get '/iterations', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'iterations' do
      assert_select 'iteration', :count => 2
    end
  end

  # Test the post /iterations request.
  def test_create_unauthorized
    num_iterations = Iteration.count
    post '/iterations', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_equal num_iterations, Iteration.count
  end

  # Test a successful post /iterations request.
  def test_create_success
    num_iterations = Iteration.count
    post '/iterations', {:iteration => {:name => 'test', :start => Date.today}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 201 # Created
    assert_select 'iteration'
    assert Iteration.find_by_name('test')
    assert_equal num_iterations+1, Iteration.count
  end

  # Test a failed post /iterations request.
  def test_create_failure
    num_iterations = Iteration.count
    post '/iterations', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Iteration.find_by_name(nil)
    assert_equal num_iterations, Iteration.count
  end

  # Test the get /iterations/id request without credentials.
  def test_show_unauthorized
    get '/iterations/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /iterations/id request.
  def test_show_success
    get '/iterations/1', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'iteration'
  end
  
  # Test the put /iterations/id request without credentials.
  def test_update_unauthorized
    put '/iterations/1', {:iteration => {:name => 'foo'}}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_nil Iteration.find_by_name('')
  end

  # Test a successful put /iterations/id request.
  def test_update_success
    put '/iterations/1', {:iteration => {:name => 'foo'}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert Iteration.find_by_name('foo')
  end

  # Test a failed put /iterations/id request.
  def test_update_failure
    put '/iterations/1', {:iteration => {:name => ''}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Iteration.find_by_name('')
  end
  
  # Test the delete /iterations/id request without credentials.
  def test_destroy_unauthorized
    delete '/iterations/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_not_nil Iteration.find_by_name('first')
  end

  # Test a successful delete /iterations/id request .
  def test_destroy_success
    delete '/iterations/1', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert_nil Iteration.find_by_name('first')
  end

  # Test a failed delete /iterations/id request.
  def test_destroy_failure
    delete '/iterations/999', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 404 # Does not exist
  end
end