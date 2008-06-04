require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexSessionTest < Test::Unit::TestCase
  fixtures :individuals
  fixtures :projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto("http://localhost/index.html", "Main") 
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test the UI (in one stream for more efficiency.
  def test_UI
    login_failed
    login_succeeded
  end 

private
  
  # Test logging in unsuccessfully.
  def login_failed
    login('quentin', 'testi')
    assert_not_nil(@ie.alert("Login Error"))
    @ie.alert("Login Error").button("OK").click
    assert_nil @ie.button("logout_button")
  end
  
  # Test logging in successfully.
  def login_succeeded
    login('Quentin', 'testit')
    logout
  end
  
  # Log in to the system with the specified credentials.
  def login( logon, password )
    @ie.text_area("userID").input(:text => logon )
    @ie.text_area("userPassword").input(:text => password )
    @ie.button("loginButton").click
  end
  
  # Log out of the system.
  def logout
    @ie.button("logoutButton").click
  end
end