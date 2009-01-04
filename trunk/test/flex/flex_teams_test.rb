require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexTeamsTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :teams
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks
  fixtures :audits

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

  # Test selection.
  def test_a_select
    init('admin2')
    select_team
  end

  # Test create (in one stream for more efficiency).
  def test_create
    init('admin2')
    create_team_failure
    create_team_success
    create_team_cancel
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    assert_equal Project.count + Team.count(:conditions => ['project_id = ?', projects(:first).id]), @ie.data_grid("projectResourceGrid").num_rows
    edit_team_failure
    edit_team_success
    edit_team_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_team_cancel
    delete_team
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert_equal 1 + Team.count(:conditions => ['project_id = ?', projects(:first).id]), @ie.data_grid("projectResourceGrid").num_rows
    assert @ie.button("teamBtnAdd")[1].visible
    assert @ie.button("projectBtnEdit")[2].visible
    assert @ie.button("projectBtnDelete")[2].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert_equal 1 + Team.count(:conditions => ['project_id = ?', projects(:first).id]), @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[2].visible
    assert !@ie.button("projectBtnDelete")[2].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert_equal 1 + Team.count(:conditions => ['project_id = ?', projects(:first).id]), @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[2].visible
    assert !@ie.button("projectBtnDelete")[2].visible
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("projectBtnEdit")[1].click
    @ie.button("projectBtnInfo").click
    assert_equal 4, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 0, @ie.data_grid("changeGrid").num_rows
  end

private

  # Test whether error handling works for creating a team.
  def create_team_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("teamBtnAdd")[1].click
    
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text
    assert !@ie.combo_box("projectFormSurveyMode").visible

    create_team('', 'description')
    @ie.button("projectBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal 'description', @ie.text_area("projectFieldDescription").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully create a team.
  def create_team_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("teamBtnAdd")[1].click
    
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text
    
    create_team('zfoo 1', 'description')

    @ie.button("projectBtnChange").click

    # Since last team ends in a number, name will be incremented.
    assert_equal 'Team was successfully created.', @ie.text_area("projectError").text
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",zfoo 1,description,,Edit | Delete | Add Team", @ie.data_grid("projectResourceGrid").tabular_data(:start => 3, :end => 3)
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a team.
  def create_team_cancel
    # Delete current teams to see what happens with default values.
    Project.find(:all).each{|team| team.destroy}
    
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("teamBtnAdd")[1].click
    create_team('foo', 'description')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Create a team.
  def create_team(name, description)
    @ie.text_area("projectFieldDescription").input(:text => description )
    @ie.text_area("projectFieldName").input(:text => name ) # Do name last due to timing issue
  end
    
  # Test whether error handling works for editing a team.
  def edit_team_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_team(' ', 'description')
    @ie.button("projectBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal ' ', @ie.text_area("projectFieldName").text
    assert_equal 'description', @ie.text_area("projectFieldDescription").text
    assert !@ie.combo_box("projectFormSurveyMode").visible
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully edit a team.
  def edit_team_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_team('foo 1', 'description')

    @ie.button("projectBtnChange").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",foo 1,description,,Edit | Delete | Add Team", @ie.data_grid("projectResourceGrid").tabular_data(:start => 1, :end => 1)
  end
    
  # Test whether you can successfully cancel editing a team.
  def edit_team_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_team('foo', 'description')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Edit a team.
  def edit_team(name, description)
    @ie.button("projectBtnEdit")[3].click
    @ie.text_area("projectFieldDescription").input(:text => description )
    @ie.text_area("projectFieldName").input(:text => name ) # Do name last due to timing issue
  end

  # Select a team to see what is displayed in individuals.
  def select_team
    @ie.data_grid("projectResourceGrid").select(:item_renderer => "Test_team")
    assert_equal 1, @ie.data_grid("individualResourceGrid").num_rows
  end
    
  # Test deleting a team.
  def delete_team_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnDelete")[2].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("projectError").text
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end
    
  # Test deleting a team.
  def delete_team
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnDelete")[2].click
    @ie.alert("Delete")[0].button("Yes").click
    sleep 1 # Wait for it to take effect.
    assert_equal '', @ie.text_area("projectError").text
    assert_equal num_rows-1, @ie.data_grid("projectResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
    (1..2).each do |i|
      @ie.data_grid("projectResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("projectResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
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
    @ie.button_bar("mainNavigation").change(:related_object => "People")
    @ie.button("projectBtnExpand")[1].click
  end
end