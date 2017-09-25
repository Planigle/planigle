require "#{File.dirname(__FILE__)}/../test_helper"

class SurveysIntegrationTest < ActionDispatch::IntegrationTest
  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :releases
  fixtures :individuals_projects
  fixtures :surveys
  fixtures :survey_mappings

  # Test creating a survey.
  def test_create_survey
    login_as(individuals(:admin2))
    get '/planigle/api/surveys/new?survey_key=' + projects(:first).survey_key, params: {}, headers: accept_header
    assert_response :success
    assert_equal 2, json.length
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid
    login_as(individuals(:admin2))
    get '/planigle/api/surveys/new?survey_key=0', params: {}, headers: accept_header
    assert_response 422
    assert json
  end

  # Test submitting a survey.
  def test_submit_survey_success
    login_as(individuals(:admin2))
    post '/planigle/api/surveys', params: {record: {:survey_key => projects(:first).survey_key, :name => 'hat', :email => 'hat@bat.com', :stories => [4, 1]}}, headers: accept_header    
    assert_response 200

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    login_as(individuals(:admin2))
    post '/planigle/api/surveys', params: {record: {:survey_key => projects(:first).survey_key, :stories => [4, 1]}}, headers: accept_header    
    assert_response 422

    assert json
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    login_as(individuals(:admin2))
    post '/planigle/api/surveys', params: {record: {:survey_key => 0, :email => 'hat@bat.com', :stories => [4, 1]}}, headers: accept_header    
    assert_response 422

    assert json
    assert_nil stories(:fourth).reload.user_priority
  end
  
  # Test listing surveys.
  def test_list_survey_unauthorized
    get '/planigle/api/surveys', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test listing surveys.
  def test_list_survey
    login_as(individuals(:admin2))
    get '/planigle/api/surveys', params: {}, headers: authorization_header
    assert_response :success
    assert Survey.where(project_id: 1).count, json.length
  end

  # Test showing a survey.
  def test_show_survey_unauthorized
    get '/planigle/api/surveys/1', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test showing a survey.
  def test_show_survey
    login_as(individuals(:admin2))
    get '/planigle/api/surveys/1', params: {}, headers: authorization_header
    assert_response :success
    assert json
  end

  # Test updating a survey.
  def test_update_survey
    login_as(individuals(:admin2))
    put '/planigle/api/surveys/2', params: {:record => {:excluded => true}}, headers: authorization_header
    assert_response :success
    assert json
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid
    login_as(individuals(:admin2))
    put '/planigle/api/surveys/0', params: {:record => {:excluded => true}}, headers: authorization_header
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized
    put '/planigle/api/surveys/2', params: {:record => {:excluded => true}}, headers: accept_header
    assert_response 401
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end
  
private
  
  def json
    JSON.parse(response.body)
  end
end