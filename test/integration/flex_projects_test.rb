require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexProjectsTest < Test::Unit::TestCase
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
    sleep 1 # Wait to ensure remember me check is made
    login('aaron', 'testit')
    sleep 3 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "Projects")
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test create (in one stream for more efficiency).
  def test_create
    cant_create
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    edit_project_failure
    edit_project_cancel
    edit_project_success
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    cant_delete
    sort_columns
  end

private

  # Test that user cannot delete.
  def cant_create
    assert !@ie.button("projectBtnCreate").visible
  end
    
  # Test whether error handling works for editing a project.
  def edit_project_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_project(' ', 'description')
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
    edit_project('foo 1', 'description')

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
    assert_equal "foo 1,description,Public by Default,Edit | Delete", @ie.data_grid("projectResourceGrid").tabular_data
  end
    
  # Test whether you can successfully cancel editing a project.
  def edit_project_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_project('foo', 'description')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Edit a project.
  def edit_project(name, description)
    @ie.button("projectBtnEdit")[1].click
    @ie.text_area("projectFieldName").input(:text => name )
    @ie.text_area("projectFieldDescription").input(:text => description )
  end
    
  # Test that user cannot delete project.
  def cant_delete
    assert !@ie.button("projectBtnDelete")[1].visible
  end
    
  # Test sorting the various columns.
  def sort_columns
    (0..1).each do |i|
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
end