require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :companies
  fixtures :stories
  fixtures :tasks
  fixtures :releases
  fixtures :iterations
  
  # Test successfully logging in.
  def test_should_login_admin
    post base_URL, params: {:login => 'quentin', :password => 'testit'}
    assert session[:individual_id]
    assert individuals(:quentin).last_login > (Time.now - 10)
    assert json
  end

  # Test successfully logging in.
  def test_should_login_selected_project
    i = individuals(:quentin)
    i.selected_project_id = 1
    i.save( :validate=> false )
    post base_URL, params: {:login => 'quentin', :password => 'testit', :conditions => {:status_code => 'NotDone', :team_id => 'MyTeam', :release_id => 'Current', :iteration_id => 'Current'}}
    assert session[:individual_id]
    assert individuals(:quentin).reload.last_login > (Time.now - 10)
    assert json
  end

  # Test successfully logging in.
  def test_should_login_project_admin
    post base_URL, params: {:login => 'aaron', :password => 'testit', :conditions => {:status_code => 'NotDone', :team_id => 'MyTeam', :release_id => 'Current', :iteration_id => 'Current'}}
    assert session[:individual_id]
    assert individuals(:aaron).last_login > (Time.now - 10)
    assert json
  end

  # Test failure to log in.
  def test_should_fail_login
    post base_URL, params: {:login => 'quentin', :password => 'bad password'}
    assert_nil session[:individual_id]
    assert_response 422
  end

  # Test logging out.
  def test_should_logout
    post base_URL, params: {:login => 'quentin', :password => 'testit'}
    assert session[:individual_id]
    delete base_URL
    assert_nil session[:individual_id]
  end

  # Test logging in should remember me.
  def test_should_remember_me
    post base_URL, params: {:login => 'quentin', :password => 'testit'}
    assert_not_nil @response.cookies["auth_token"]
  end

  # Test that logging out removes remember me.
  def test_should_delete_token_on_logout
    post base_URL, params: {:login => 'quentin', :password => 'testit'}
    assert_not_nil @response.cookies["auth_token"]
    delete base_URL
    assert_nil @response.cookies["auth_token"]
  end

  # Test that cookie's presence results in automatic login.
  def test_should_login_with_cookie
    individuals(:quentin).remember_me
    individuals(:quentin).save( :validate=> false )
    cookies['auth_token'] = cookie_for(:quentin)
    get '/planigle/api/stories'
    assert_response :success
  end

  # Test that an expired cookie does not log you in.
  def test_should_fail_expired_cookie_login
    individuals(:quentin).remember_me
    individuals(:quentin).save( :validate=> false )
    individuals(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    cookies['auth_token'] = cookie_for(:quentin)
    get '/planigle/api/stories'
    assert_response 401
  end

  # Test that if the server doesn't know about the remember me cookie, it is ignored.
  def test_should_fail_cookie_login
    individuals(:quentin).remember_me
    individuals(:quentin).save( :validate=> false )
    cookies['auth_token'] = auth_token('invalid_auth_token')
    get '/planigle/api/stories'
    assert_response 401
  end

  # Verify that if there is a license agreement, the user should have to accept
  def test_should_require_accept_license
    system = System.first
    system.license_agreement = "You must accept"
    system.save( :validate=> false )
    post base_URL, params: {:login => 'quentin', :password => 'testit'}
    assert_response 422
    assert json['error']
    assert json['agreement']
    assert_nil session[:individual_id]
    
    post base_URL, params: {:login => 'quentin', :password => 'testit', :accept_agreement => "true"}
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
    individuals(individual).remember_token
  end

  def json
    JSON.parse(response.body)
  end
  
  def base_URL
    '/planigle/api/session'
  end
end