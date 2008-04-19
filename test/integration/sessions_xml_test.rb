require "#{File.dirname(__FILE__)}/../test_helper"
require "application"

# Ensure we don't get redirected to https.
ApplicationController.ssl_supported=false

class SessionsXmlTest < ActionController::IntegrationTest
  fixtures :individuals
  
  # Test a successful login (without headers).
  def test_create_success_flex
    post '/session.xml', {:login => 'quentin', :password => 'testit'}, flex_header
    assert_response 200 # Created

    get '/individuals.xml', {}, flex_header
    assert_response  200 # Successful
    assert_select 'individuals' do
      assert_select 'individual', :count => 2    
    end
  end

  # Test a failed login (without headers).
  def test_create_failure_flex
    post '/session.xml', {:login => 'quentin', :password => 'notmypassword'}, flex_header
    assert_response 200 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end

    get '/individuals.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end

  # Test a successful logout (without headers).
  def test_destroy_success_flex
    post '/session.xml', {:login => 'quentin', :password => 'testit'}, flex_header
    assert_response 200 # OK

    get '/individuals.xml', {}, flex_header
    assert_response 200 # OK
    assert_select 'individuals' do
      assert_select 'individual', :count => 2    
    end

    delete '/session.xml', {}, flex_header
    assert_response 200 # OK

    get '/individuals.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end
end