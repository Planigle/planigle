require "#{File.dirname(__FILE__)}/../test_helper"

class SurveysXmlTest < ActionController::IntegrationTest

  fixtures :individuals
  fixtures :stories
  fixtures :projects
  fixtures :surveys
  fixtures :survey_mappings

  # Re-raise errors caught by the controller.
  class SurveysController; def rescue_action(e) raise e end; end

  # Test creating a survey.
  def test_create_survey
    get '/surveys/new?survey_key=' + projects(:first).survey_key, {}, accept_header
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

  # Test creating a survey.
  def test_create_survey_flex
    get '/surveys/new.xml?survey_key=' + projects(:first).survey_key, {}, flex_header
    assert_response :success

    assert_select 'stories' do
      assert_select 'story', 2 do
        assert_select 'id'
        assert_select 'name'
        assert_select 'description'
        assert_select 'priority'
      end
    end
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid
    get '/surveys/new?survey_key=0', {}, accept_header
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid_flex
    get '/surveys/new?survey_key=0.xml', {}, flex_header
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    post '/surveys?survey_key=' + projects(:first).survey_key, {:name => 'hat', :email => 'hat@bat.com', :stories => [4, 1]}, accept_header    
    assert_response 201

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey.
  def test_submit_survey_success_flex
    post '/surveys.xml?survey_key=' + projects(:first).survey_key, {:name => 'hat', :email => 'hat@bat.com', :stories => [4, 1]}, flex_header    
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    post '/surveys?survey_key=' + projects(:first).survey_key, {:stories => [4, 1]}, accept_header    
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure_flex
    post '/surveys.xml?survey_key=' + projects(:first).survey_key, {:stories => [4, 1]}, flex_header    
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    post '/surveys?survey_key=0', {:email => 'hat@bat.com', :stories => [4, 1]}, accept_header    
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid_flex
    post '/surveys.xml?survey_key=0', {:email => 'hat@bat.com', :stories => [4, 1]}, flex_header
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end
  
  # Test listing surveys.
  def test_list_survey_unauthorized
    get '/surveys', {}, accept_header
    assert_response 401 # Unauthorized
  end
  
  # Test listing surveys.
  def test_list_survey_unauthorized_flex
    get '/surveys.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end

  # Test listing surveys.
  def test_list_survey
    get '/surveys', {}, authorization_header
    assert_response :success

    assert_select 'surveys' do
      assert_select 'survey', Survey.count do
        assert_select 'id'
        assert_select 'name'
        assert_select 'company'
        assert_select 'email'
        assert_select 'excluded'
      end
    end
  end

  # Test listing surveys.
  def test_list_survey_flex
    flex_login
    get '/surveys.xml', {}, flex_header
    assert_response :success

    assert_select 'surveys' do
      assert_select 'survey', Survey.count do
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
    get '/surveys/1', {}, accept_header
    assert_response 401 # Unauthorized
  end

  # Test showing a survey.
  def test_show_survey_unauthorized_flex
    get '/surveys/1.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end

  # Test showing a survey.
  def test_show_survey
    get '/surveys/1', {}, authorization_header
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

  # Test showing a survey.
  def test_show_survey_flex
    flex_login
    get '/surveys/1.xml', {}, flex_header
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
    put '/surveys/2', {:record => {:excluded => true}}, authorization_header
    assert_response :success
    assert_select 'survey'
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey.
  def test_update_survey_flex
    flex_login
    put '/surveys/2.xml', {:record => {:excluded => true}}, flex_header
    assert_response :success
    assert_select 'survey'
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid
    put '/surveys/0', {:record => {:excluded => true}}, authorization_header
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid_flex
    flex_login
    put '/surveys/0.xml', {:record => {:excluded => true}}, flex_header
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized
    put '/surveys/2', {:record => {:excluded => true}}, accept_header
    assert_response 401
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized_flex
    put '/surveys/2.xml', {:record => {:excluded => true}}, flex_header
    assert_response 401
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end
end