require "#{File.dirname(__FILE__)}/../test_helper"

class IndividualsXmlTest < ActionController::IntegrationTest
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  # Re-raise errors caught by the controller.
  class IndividualsController; def rescue_action(e) raise e end; end

  # Test the get /individuals request without credentials.
  def test_index_unauthorized
    get '/individuals', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /individuals request.
  def test_index_success
    get '/individuals', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'individuals' do
      assert_select 'individual', :count => 2    
    end
  end

  # Test the post /individuals request.
  def test_create_unauthorized
    num_individuals = Individual.count
    post '/individuals', {:individual => {:login => 'foo', :email => 'foo@sample.com', :last_name => 'bar',
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_equal num_individuals, Individual.count
  end

  # Test a successful post /individuals request.
  def test_create_success
    num_individuals = Individual.count
    post '/individuals', {:individual => {:login => 'foo', :email => 'foo@sample.com', :last_name => 'bar',
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 201 # Created
    assert_select 'individual'
    assert Individual.find_by_login('foo')
    assert_equal ActionMailer::Base.deliveries.length, 1
    assert_equal num_individuals + 1, Individual.count
  end

  # Test a failed post /individuals request.
  def test_create_failure
    num_individuals = Individual.count
    post '/individuals', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Individual.find_by_login(nil)
    assert_equal num_individuals, Individual.count
  end

  # Test the get /individuals/id request without credentials.
  def test_show_unauthorized
    get '/individuals/1', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful get /individuals/id request.
  def test_show_success
    get '/individuals/1', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response :success
    assert_select 'individual'
  end
  
  # Test the put /individuals/id request without credentials.
  def test_update_unauthorized
    put '/individuals/1', {:individual => {:login => 'foo'}}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
  end

  # Test a successful put /individuals/id request.
  def test_update_success
    put '/individuals/1', {:individual => {:login => 'foo'}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert Individual.find_by_login('foo')
  end

  # Test a failed put /individuals/id request.
  def test_update_failure
    put '/individuals/1', {:individual => {:login => ''}}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil Individual.find_by_login('')
  end
  
  # Test the delete /individuals/id request without credentials.
  def test_destroy_unauthorized
    delete '/individuals/2', {}, {'Accept' => 'text/xml'}
    assert_response 401 # Unauthorized
    assert_not_nil Individual.find_by_login('aaron')
  end

  # Test a successful delete /individuals/id request .
  def test_destroy_success
    delete '/individuals/2', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 200 # Success
    assert_nil Individual.find_by_login('aaron')
  end

  # Test a failed delete /individuals/id request.
  def test_destroy_failure
    delete '/individuals/999', {}, {'Authorization' => authorization_header('quentin', 'testit'), 'Accept' => 'text/xml'}
    assert_response 404 # Does not exist
  end
end
