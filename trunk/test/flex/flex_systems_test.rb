require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexSystemsTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :companies
  fixtures :projects
  fixtures :individuals
  fixtures :individuals_projects

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto("http://localhost:3000/index.html", "Main") 
    sleep 1 # Wait to ensure remember me check is made
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    @ie.button_bar("mainNavigation").change(:related_object => "System")
    edit_system_success
    edit_system_cancel
  end 

  # Test logging in as a system admin
  def test_system_admin
    init('aaron')
    verify_no_system
  end

  # Test logging in as a system user
  def test_system_user
    init('user')
    verify_no_system
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    verify_no_system
  end

private
    
  # Test whether you can successfully edit a system.
  def edit_system_success
    @ie.text_area("systemAgreement").input(:text => "agreement2" )
    @ie.button("okBtn").click
    Fixtures.reset_cache # Since we have a separate process changing the database
    assert_equal "agreement2", System.find(:first).reload.license_agreement
  end
    
  # Test whether you can successfully cancel editing a system.
  def edit_system_cancel
    @ie.text_area("systemAgreement").input(:text =>  "agreement3" )
    @ie.button("cancelBtn").click
    Fixtures.reset_cache # Since we have a separate process changing the database
    assert "agreement3" !=  System.find(:first).reload.license_agreement
  end

  # Verify that there is no System tab.
  def verify_no_system
    begin
      @ie.button_bar("mainNavigation").change(:related_object => "System")
      assert false # Shouldn't get to this point
    rescue Exception
    end  
  end
      
  # Log in to the system with the specified credentials.
  def login( logon, password )
    @ie.text_area("userID").input(:text => logon )
    @ie.text_area("userPassword").input(:text => password )
    @ie.button("loginButton").click
  end
  
  # Initialize for a particular logon
  def init( logon )
    login(logon, 'testit')
    sleep 3 # Wait to ensure data loaded
  end
end