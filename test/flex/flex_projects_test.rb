require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexProjectsTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
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
    select_project
  end

  # Test create (in one stream for more efficiency).
  def test_create
    init('admin2')
    assert_equal Project.count, @ie.data_grid("projectResourceGrid").num_rows
    create_project_failure
    create_project_success
    create_project_cancel
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    edit_project_failure
    edit_project_success
    edit_project_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_project_cancel
    delete_project
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert_equal 1, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert @ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert_equal 1, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert_equal 1, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("projectBtnInfo")[1].click
    assert_equal 4, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 0, @ie.data_grid("changeGrid").num_rows
  end

private

  # Test whether error handling works for creating a project.
  def create_project_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text

    create_project('', 'description')
    @ie.button("projectBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal 'description', @ie.text_area("projectFieldDescription").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully create a project.
  def create_project_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text
    
    create_project('zfoo 1', 'description')

    assert @ie.form_item("projectFormSurveyUrl").visible
    assert_equal "Will be assigned on creation", @ie.label("projectLabelSurveyUrl").text
    @ie.combo_box("projectFieldSurveyMode").open
    @ie.combo_box("projectFieldSurveyMode").select(:item_renderer => "Private")
    assert !@ie.form_item("projectFormSurveyUrl").visible

    @ie.button("projectBtnChange").click

    # Since last project ends in a number, name will be incremented.
    assert_equal 'Project was successfully created.', @ie.text_area("projectError").text
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_equal '', @ie.text_area("projectFieldDescription").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",zfoo 1,description,Private,Edit | Delete | Add Team | History", @ie.data_grid("projectResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a project.
  def create_project_cancel
    # Delete current projects to see what happens with default values.
    Project.find(:all).each{|project| project.destroy}
    
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    create_project('foo', 'description')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Create a project.
  def create_project(name, description)
    @ie.text_area("projectFieldName").input(:text => name )
    @ie.text_area("projectFieldDescription").input(:text => description )
  end
    
  # Test whether error handling works for editing a project.
  def edit_project_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_project(' ', 'description', '10/10/2020', '10')
    @ie.button("projectBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal ' ', @ie.text_area("projectFieldName").text
    assert_equal 'description', @ie.text_area("projectFieldDescription").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully edit a project.
  def edit_project_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_project('foo 1', 'description', '10/10/2020', '10')

    @ie.combo_box("projectFieldSurveyMode").open
    @ie.combo_box("projectFieldSurveyMode").select(:item_renderer => "Private")
    assert !@ie.form_item("projectFormSurveyUrl").visible
    @ie.combo_box("projectFieldSurveyMode").open
    @ie.combo_box("projectFieldSurveyMode").select(:item_renderer => "Public by Default")
    assert @ie.form_item("projectFormSurveyUrl").visible
    assert_equal "http://localhost:3000/survey.html?projectid=1&surveykey=" + projects(:first).survey_key, @ie.label("projectLabelSurveyUrl").text

    @ie.button("projectBtnChange").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",foo 1,description,Public by Default,Edit | Delete | Add Team | History", @ie.data_grid("projectResourceGrid").tabular_data
  end
    
  # Test whether you can successfully cancel editing a project.
  def edit_project_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_project('foo', 'description', '10/10/2020', '10')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Edit a project.
  def edit_project(name, description, premium_expiry, premium_limit)
    @ie.button("projectBtnEdit")[1].click
    @ie.text_area("projectFieldName").input(:text => name )
    @ie.text_area("projectFieldDescription").input(:text => description )
    @ie.text_area("projectFieldPremiumExpiry").input(:text => premium_expiry )
    @ie.text_area("projectFieldPremiumLimit")[0].input(:text => premium_limit ) # Not sure why the array is necessary
  end

  # Select a project to see what is displayed in individuals.
  def select_project
    @ie.data_grid("projectResourceGrid").select(:item_renderer => "Test")
    assert_equal 5, @ie.data_grid("individualResourceGrid").num_rows
  end
    
  # Test deleting a project.
  def delete_project_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnDelete")[2].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("projectError").text
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end
    
  # Test deleting a project.
  def delete_project
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
  end
end