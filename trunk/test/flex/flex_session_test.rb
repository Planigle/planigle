require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexSessionTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto("http://localhost:3000/index.html", "Main") 
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test the UI (in one stream for more efficiency.
  def test_UI
    login_failed
    login_succeeded
    login_cookie
  end
  
  # Test going through the license agreement
  def test_agreement
    login("quentin", "testit")
    sleep 5 # Wait for response
    @ie.button_bar("mainNavigation").change(:related_object => "System")
    @ie.text_area("systemAgreement").input(:text => "new agreement" )
    @ie.button("okBtn").click
    logout
    sleep 1
    login("quentin", "testit")
    sleep 2 # Wait for response
    @ie.button("noButton").click
    @ie.alert("License Agreement")[0].button("OK").click
    @ie.button("yesButton").click
    sleep 5 # Wait for data to load
    assert @ie.button("logoutButton")
  end
  
  # Test signing up for an account.
  def test_signup
    @ie.button("signupButton").click
    @ie.text_area("signupFieldName").input(:text => ' ' )
    @ie.text_area("signupFieldDescription").input(:text => 'description' )
    @ie.text_area("signupFieldLogin").input(:text => 'login' )
    @ie.text_area("signupFieldPassword").input(:text => 'password' )
    @ie.text_area("signupFieldPasswordConfirmation").input(:text => 'password' )
    @ie.text_area("signupFieldEmail").input(:text => 'xzcvg@kasjhuj.com' )
    @ie.text_area("signupFieldFirstName").input(:text => 'test' )
    @ie.text_area("signupFieldLastName").input(:text => 'ignore' )    
    @ie.button("okButton").click
    assert_equal "Name can't be blank", @ie.text_area("signupError").text
    @ie.text_area("signupFieldName").input(:text => 'foobar' )
    @ie.button("okButton").click
    assert_equal "You have successfully signed up for Planigle.  Shortly, you will receive an email to complete the signup process.", @ie.text_area("signupError").text
    assert !@ie.box("signupBtnBox").visible
  end

  # Test canceling signing up.
  def test_cancel_signup
    @ie.button("signupButton").click
    @ie.button("cancelButton").click
    assert @ie.button("loginButton").visible
  end

private
  
  # Test logging in unsuccessfully.
  def login_failed
    sleep 1 # Wait to ensure remember me check is made
    login('quentin', 'testi')
    sleep 1
    assert_not_nil(@ie.alert("Login Error"))
    @ie.alert("Login Error").button("OK").click
    assert_nil @ie.button("logoutButton")
  end
  
  # Test logging in successfully.
  def login_succeeded
    sleep 1 # Wait to ensure remember me check is made
    login('Quentin', 'testit')
    sleep 3 # Wait to ensure data loaded
    assert @ie.button("logoutButton")
    assert_no_tab "Schedule"
    assert_no_tab "Stories"
    logout
  end
  
  # Test logging in with remember me.
  def login_cookie
    sleep 1 # Wait to ensure remember me check is made
    login('Quentin', 'testit', true)
    sleep 3 # Wait to ensure data loaded
    @ie.goto("http://localhost:3000/index.html", "Main") 
    sleep 12 # Wait to ensure data loaded
    assert @ie.button("logoutButton") # should succeed because cookie skips log in.
    logout
    @ie.goto("http://localhost:3000/index.html", "Main") 
    sleep 5 # Wait to ensure data not loaded
    assert_nil @ie.button("logoutButton") # should now fail since log out erases cookie
  end
  
  # Log in to the system with the specified credentials.
  def login( logon, password, remember_me = false )
    @ie.text_area("userID").input(:text => logon )
    @ie.text_area("userPassword").input(:text => password )
    if remember_me
      @ie.check_box("rememberMe").click
    end
    @ie.button("loginButton").click
  end
  
  # Log out of the system.
  def logout
    @ie.button("logoutButton").click
  end
  
  # Assert that the tab does not exist.
  def assert_no_tab( tab_name )
    begin
      @ie.button_bar("mainNavigation").change(:related_object => tab_name)
      assert false
    rescue
    end
  end
end