require "#{File.dirname(__FILE__)}/../test_helper"

class SessionsXmlTest < ActionController::IntegrationTest
  fixtures :individuals

  # Test a successful login (without headers).
  def test_create_success
    post '/session.xml', {:login => 'quentin', :password => 'testit'}
    assert_response 201 # Created

    get '/individuals.xml'
    assert_response  200 # Successful
    assert_select 'individuals' do
      assert_select 'individual', :count => 2    
    end
  end

  # Test a failed login (without headers).
  def test_create_failure
    post '/session.xml', {:login => 'quentin', :password => 'notmypassword'}
    assert_response 422 # Unprocessable Entity

    get '/individuals.xml'
    assert_response 401 # Unauthorized
  end

  # Test a successful logout (without headers).
  def test_destroy_success
    post '/session.xml', {:login => 'quentin', :password => 'testit'}
    assert_response 201 # Created

    get '/individuals.xml'
    assert_response 200 # Successful
    assert_select 'individuals' do
      assert_select 'individual', :count => 2    
    end

    delete '/session.xml'
    assert_response 200 # Successful

    get '/individuals.xml'
    assert_response 401 # Unauthorized
  end
end
