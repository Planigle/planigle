require "#{File.dirname(__FILE__)}/../test_helper"

class SurveysIntegrationTest < ActionDispatch::IntegrationTest

  fixtures :systems
  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :individuals_projects
  fixtures :surveys
  fixtures :survey_mappings

  # Re-raise errors caught by the controller.
  class SurveysController; def rescue_action(e) raise e end; end

  # Test creating a survey.
  def test_create_survey
    get '/surveys/new?survey_key=' + projects(:first).survey_key, params: {}, headers: accept_header
    assert_response :success

    assert_select 'stories' do
      assert_select 'story', 2 do
        assert_select 'id'
        assert_select 'story'
        assert_select 'description'
        assert_select 'priority'
      end
    end
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid
    get '/surveys/new?survey_key=0', params: {}, headers: accept_header
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    post '/surveys?survey_key=' + projects(:first).survey_key, params: {:name => 'hat', :email => 'hat@bat.com', :stories => [4, 1]}, headers: accept_header    
    assert_response 201

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    post '/surveys?survey_key=' + projects(:first).survey_key, params: {:stories => [4, 1]}, headers: accept_header    
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    post '/surveys?survey_key=0', params: {:email => 'hat@bat.com', :stories => [4, 1]}, headers: accept_header    
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end
  
  # Test listing surveys.
  def test_list_survey_unauthorized
    get '/surveys', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test listing surveys.
  def test_list_survey
    get '/surveys', params: {}, headers: authorization_header
    assert_response :success

    assert_select 'surveys' do
      assert_select 'survey', Survey.where(project_id: 1).count do
        assert_select 'id'
        assert_select 'name'
        assert_select 'company'
        assert_select 'email'
        assert_select 'excluded'
      end
    end
  end

  # Test showing a survey.
  def test_show_survey_unauthorized
    get '/surveys/1', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test showing a survey.
  def test_show_survey
    get '/surveys/1', params: {}, headers: authorization_header
    assert_response :success

    assert_select 'survey' do
      assert_select 'id'
      assert_select 'name'
      assert_select 'company'
      assert_select 'email'
      assert_select 'excluded'
      assert_select 'survey-mappings' do
        assert_select 'survey-mapping' do
          assert_select 'story-id'
          assert_select 'priority'
        end
      end
    end
  end

  # Test updating a survey.
  def test_update_survey
    put '/surveys/2', params: {:record => {:excluded => true}}, headers: authorization_header
    assert_response :success
    assert_select 'survey'
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid
    put '/surveys/0', params: {:record => {:excluded => true}}, headers: authorization_header
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized
    put '/surveys/2', params: {:record => {:excluded => true}}, headers: accept_header
    assert_response 401
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end
end