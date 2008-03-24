require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  fixtures :individuals

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test successfully logging in.
  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'testit'
    assert session[:individual_id]
    assert_response :redirect
  end

  # Test failure to log in.
  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:individual_id]
    assert_response :success
    assert_template 'new'
  end

  # Test logging out.
  def test_should_logout
    post :create, :login => 'quentin', :password => 'testit'
    assert session[:individual_id]
    get :destroy
    assert_nil session[:individual_id]
    assert_response :redirect
  end

  # Test setting remember me.
  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  # Test turning off remember me.
  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  # Test that logging out removes remember me.
  def test_should_delete_token_on_logout
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  # Test that cookie's presence results in automatic login.
  def test_should_login_with_cookie
    individuals(:quentin).remember_me
    individuals(:quentin).save(false)
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  # Test that an expired cookie does not log you in.
  def test_should_fail_expired_cookie_login
    individuals(:quentin).remember_me
    individuals(:quentin).save(false)
    individuals(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  # Test that if the server doesn't know about the remember me cookie, it is ignored.
  def test_should_fail_cookie_login
    individuals(:quentin).remember_me
    individuals(:quentin).save(false)
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

private

  # Return the cookie for remember me given a token.
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
  # Return the cookie for remember me for an individual.
  def cookie_for(individual)
    auth_token individuals(individual).remember_token
  end
end