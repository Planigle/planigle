require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexSurveysTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :iterations
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test getting the survey.
  def test_get_survey
    get_invalid_survey
    get_survey_success
  end

  # Test getting a survey with an invalid code.
  def get_invalid_survey
    @ie.goto("http://localhost:3000/survey.html?projectid=1&surveykey=0", "Survey") 
    sleep 2 # Wait for survey to load
    assert_equal 'Invalid survey key', @ie.text_area("error").text
    assert !@ie.button("btnSubmit").visible
  end
  
  # Test getting a survey successfully.
  def get_survey_success
    @ie.goto("http://localhost:3000/survey.html?projectid=1&surveykey=" + projects(:first).survey_key, "Survey")
    sleep 2 # Wait for survey to load
    assert_equal 'Drag and drop the stories to order them from most important to least important and then hit Submit', @ie.text_area("error").text
    assert @ie.button("btnSubmit").visible
    assert_equal 2, @ie.data_grid("resourceGrid").num_rows
    assert_equal "test,description,1", @ie.data_grid("resourceGrid").tabular_data(:start => 0, :end => 0)
    assert_equal "test4,,2", @ie.data_grid("resourceGrid").tabular_data(:start => 1, :end => 1)
  end

  # Test submitting a survey.
  def test_submit
    submit_without_email
    submit_successful
  end

  # Test submitting without an email.
  def submit_without_email
    @ie.goto("http://localhost:3000/survey.html?projectid=1&surveykey=" + projects(:first).survey_key, "Survey") 
    sleep 2 # Wait for survey to load
    @ie.button("btnSubmit").click
    assert_equal "Name can't be blank\rEmail can't be blank\rEmail is too short (minimum is 6 characters)", @ie.text_area("error").text
    assert @ie.button("btnSubmit").visible
  end
  
  # Test submitting successfully.
  def submit_successful
    @ie.goto("http://localhost:3000/survey.html?projectid=1&surveykey=" + projects(:first).survey_key, "Survey") 
    sleep 2 # Wait for survey to load
    @ie.text_area("fieldName").input(:text => 'Testy' )
    @ie.text_area("fieldCompany").input(:text => 'Foo' )
    @ie.text_area("fieldEmail").input(:text => 'testy@foo.com' )
    @ie.button("btnSubmit").click
    sleep 3 # Wait for survey submission
    assert_equal 'Survey submitted successfully!  Thanks for your help.', @ie.text_area("error").text
    assert !@ie.button("btnSubmit").visible
  end
end