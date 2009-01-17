require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'
require 'application'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase
  fixtures :systems
  fixtures :individuals

  # Test successfully logging in.
  def test_should_login
    post :create, :login => 'quentin', :password => 'testit', :format => 'xml'
    assert session[:individual_id]
    assert individuals(:quentin).last_login > (Time.now - 10)
    assert_select 'current-individual', 1
    assert_select 'system', 1
    assert_select 'release', false
    assert_select 'iteration', false
    assert_select 'story', false
    assert_select 'project', Project.count
    assert_select 'individual', Individual.count

    post :create, :login => 'aaron', :password => 'testit', :format => 'xml'
    assert session[:individual_id]
    assert individuals(:aaron).last_login > (Time.now - 10)
    assert_select 'current-individual', 1
    assert_select 'system', 1
    assert_select 'release', Release.find_all_by_project_id(1).length
    assert_select 'iteration', Iteration.find_all_by_project_id(1).length
    assert_select 'story', Story.find_all_by_project_id(1).length
    assert_select 'project', 2
    assert_select 'individual', Individual.find_all_by_company_id(1, :conditions => "role != 0").length
  end

  # Test failure to log in.
  def test_should_fail_login
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:individual_id]
    assert_response :success
  end

  # Test logging out.
  def test_should_logout
    post :create, :login => 'quentin', :password => 'testit'
    assert session[:individual_id]
    delete :destroy
    assert_nil session[:individual_id]
  end

  # Test setting remember me.
  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "true"
    assert_not_nil @response.cookies["auth_token"]
  end

  # Test turning off remember me.
  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "false"
    assert_nil @response.cookies["auth_token"]
  end
  
  # Test that logging out removes remember me.
  def test_should_delete_token_on_logout
    post :create, :login => 'quentin', :password => 'testit', :remember_me => "true"
    assert_not_nil @response.cookies["auth_token"]
    delete :destroy
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

  # Verify that if there is a license agreement, the user should have to accept
  def test_should_require_accept_license
    system = System.find(:first)
    system.license_agreement = "You must accept"
    system.save(false)
    post :create, :login => 'quentin', :password => 'testit', :format => 'xml'
    assert_response 422
    assert_select "error"
    assert_select "agreement"
    assert_nil session[:individual_id]
    
    post :create, :login => 'quentin', :password => 'testit', :accept_agreement => "true", :format => 'xml'
    assert session[:individual_id]
    assert individuals(:quentin).accepted_agreement > (Time.now - 10)
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