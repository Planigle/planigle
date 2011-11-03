require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexSessionTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories
  fixtures :releases
  fixtures :iterations
  fixtures :tasks
  fixtures :teams
  fixtures :story_values
  fixtures :story_attributes
  fixtures :story_attribute_values

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto(ENV['test_host']+"/index.html", "Main") 
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
    @ie.text_area("signupFieldCompany").input(:text => ' ' )
    @ie.text_area("signupFieldName").input(:text => ' ' )
    @ie.text_area("signupFieldDescription").input(:text => 'description' )
    @ie.text_area("signupFieldLogin").input(:text => 'login' )
    @ie.text_area("signupFieldPassword").input(:text => 'password' )
    @ie.text_area("signupFieldPasswordConfirmation").input(:text => 'password' )
    @ie.text_area("signupFieldEmail").input(:text => 'xzcvg@kasjhuj.com' )
    @ie.text_area("signupFieldPhoneNumber").input(:text => '5555555555' )
    @ie.text_area("signupFieldFirstName").input(:text => 'test' )
    @ie.text_area("signupFieldLastName").input(:text => 'ignore' )    
    @ie.button("okButton").click
    assert_equal "Name can't be blank", @ie.text_area("signupError").text
    @ie.text_area("signupFieldCompany").input(:text => 'company' )
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
  
  # Test switching projects
  def test_switch_project_admin
    login("quentin", "testit")
    sleep(5)
    assert_equal 2, @ie.button_bar("mainNavigation").numChildren
    @ie.combo_box("selectedProject").open
    @ie.combo_box("selectedProject").select(:item_renderer => 'Test_company: Test' )
    sleep(5)
    assert_equal 6, @ie.button_bar("mainNavigation").numChildren
    @ie.combo_box("selectedProject").open
    @ie.combo_box("selectedProject").select(:item_renderer => 'Test2_company: Test2' )
    sleep(5)
    assert_equal 5, @ie.button_bar("mainNavigation").numChildren
    @ie.button_bar("mainNavigation").change(:related_object => "Stories")
    assert_equal 1, @ie.data_grid("storyResourceGrid").num_rows
    assert @ie.button("storyBtnCreate").visible
    @ie.button_bar("mainNavigation").change(:related_object => "Schedule")
    assert_equal 2, @ie.data_grid("releaseResourceGrid").num_rows
    assert @ie.button("releaseBtnCreate").visible
    assert_equal 2, @ie.data_grid("iterationResourceGrid").num_rows
    assert @ie.button("iterationBtnCreate").visible
  end
  
  # Test switching projects
  def test_switch_project_project_admin
    login("aaron", "testit")
    sleep(5)
    @ie.combo_box("selectedProject").open
    @ie.combo_box("selectedProject").select(:item_renderer => 'Test3' )
    sleep(5)
    assert_equal 0, @ie.data_grid("storyResourceGrid").num_rows
    assert @ie.button("storyBtnCreate").visible
    @ie.button_bar("mainNavigation").change(:related_object => "Schedule")
    assert_equal 0, @ie.data_grid("releaseResourceGrid").num_rows
    assert @ie.button("releaseBtnCreate").visible
    assert_equal 0, @ie.data_grid("iterationResourceGrid").num_rows
    assert @ie.button("iterationBtnCreate").visible
  end
  
  # Test switching projects
  def test_switch_project_project_user
    login("user4", "testit")
    sleep(5)
    @ie.combo_box("selectedProject").open
    @ie.combo_box("selectedProject").select(:item_renderer => 'Test3' )
    sleep(5)
    assert_equal 0, @ie.data_grid("storyResourceGrid").num_rows
    assert !@ie.button("storyBtnCreate").visible
    @ie.button_bar("mainNavigation").change(:related_object => "Schedule")
    assert_equal 0, @ie.data_grid("releaseResourceGrid").num_rows
    assert !@ie.button("releaseBtnCreate").visible
    assert_equal 0, @ie.data_grid("iterationResourceGrid").num_rows
    assert !@ie.button("iterationBtnCreate").visible
  end
  
  # Test url with all
  def test_URL_all
    @ie.goto(ENV['test_host']+"/index.html?project_id=1", "Main") 
    login("aaron", "testit")
    sleep 1
    assert_equal 4, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal "All Releases", @ie.combo_box("release").text
    assert_equal "All Iterations", @ie.combo_box("iteration").text
    assert_equal "All Teams", @ie.combo_box("team").text
    assert_equal "All Owners ", @ie.combo_box("individual").text
    assert_equal "All Statuses", @ie.combo_box("itemStatus").text
  end
    
  # Test url with selected
  def test_URL_selected
    @ie.goto(ENV['test_host']+"/index.html?project_id=1&release_id=1&iteration_id=1&team_id=1&team_id=1&individual_id=2&status_code=1&custom_5=1", "Main") 
    login("aaron", "testit")
    sleep 1
    assert_equal 1, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal "first", @ie.combo_box("release").text
    assert_equal "first", @ie.combo_box("iteration").text
    assert_equal "Test_team", @ie.combo_box("team").text
    assert_equal "aaron hank", @ie.combo_box("individual").text
    assert_equal "In Progress", @ie.combo_box("itemStatus").text
    assert_equal "Value 1", @ie.combo_box("searchField5").text
  end
    
  # Test url with none selected
  def test_URL_None
    @ie.goto(ENV['test_host']+"/index.html?project_id=&release_id=&iteration_id=&team_id=&team_id=&individual_id=&status_code=NotDone&custom_5=", "Main") 
    login("aaron", "testit")
    sleep 1
    assert_equal 2, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal "No Release", @ie.combo_box("release").text
    assert_equal "Backlog", @ie.combo_box("iteration").text
    assert_equal "No Team", @ie.combo_box("team").text
    assert_equal "No Owner", @ie.combo_box("individual").text
    assert_equal "Not Done", @ie.combo_box("itemStatus").text
    assert_equal "None", @ie.combo_box("searchField5").text
  end
    
  # Test url with story selected
  def test_URL_Specific_Story
    @ie.goto(ENV['test_host']+"/index.html?project_id=1&id=1", "Main") 
    login("aaron", "testit")
    sleep 1
    assert_equal 1, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal 'test', @ie.text_area("storyFieldName").text
  end
    
  # Test url with task selected
  def test_URL_Specific_Task
    @ie.goto(ENV['test_host']+"/index.html?project_id=1&tasks.id=1", "Main") 
    login("aaron", "testit")
    sleep 1
    assert_equal 2, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal 'test_task', @ie.text_area("storyFieldName").text
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
    new_browser
    sleep 5 # Wait to ensure data loaded
    assert @ie.button("logoutButton") # should succeed because cookie skips log in.
    logout
    new_browser
    sleep 5 # Wait to ensure data not loaded
    assert_nil @ie.button("logoutButton") # should now fail since log out erases cookie
  end

  def new_browser
    @ie.unload
    sleep 2
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto(ENV['test_host']+"/index.html", "Main") 
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