require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexAuditsTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks
  fixtures :audits

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto(ENV['test_host']+"/index.html", "Main") 
    sleep 1 # Wait to ensure remember me check is made
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test searching.
  def test_search
    init('admin2')
    @ie.combo_box("changesChanger").open
    @ie.combo_box("changesChanger").scroll(:position => '0')
    @ie.combo_box("changesChanger").select(:item_renderer => 'aaron hank' )
    @ie.combo_box("changesObjectType").open
    @ie.combo_box("changesObjectType").scroll(:position => '4')
    @ie.combo_box("changesObjectType").select(:item_renderer => 'Story' )
    @ie.text_area("changesStartDate").input(:text => '11/01/08' )
    @ie.text_area("changesEndDate").input(:text => '11/02/08' )
    @ie.button("searchBtn").click
    assert_equal 2, @ie.data_grid("changeGrid").num_rows
  end

  # Test sorting.
  def test_misc
    init('admin2')
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
  end

private

  # Test sorting the various columns.
  def sort_columns
    (0..5).each do |i|
      @ie.data_grid("changeGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("changeGrid").header_click(:columnIndex => i.to_s) # Sort both ways
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
    sleep 5 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "Changes")
    sleep 1
  end
end