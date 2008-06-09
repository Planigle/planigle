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
    get '/surveys/' + projects(:first).survey_key, {}, accept_header
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
    get '/surveys/' + projects(:first).survey_key + '.xml', {}, flex_header
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
    get '/surveys/0', {}, accept_header
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid_flex
    get '/surveys/0.xml', {}, flex_header
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    put '/surveys/' + projects(:first).survey_key, {:email => 'hat@bat.com', :stories => [4, 1]}, accept_header    
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey.
  def test_submit_survey_success_flex
    put '/surveys/' + projects(:first).survey_key + '.xml', {:email => 'hat@bat.com', :stories => [4, 1]}, flex_header    
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    put '/surveys/' + projects(:first).survey_key, {:stories => [4, 1]}, accept_header    
    assert_response 422

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure_flex
    put '/surveys/' + projects(:first).survey_key + '.xml', {:stories => [4, 1]}, flex_header    
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    put '/surveys/0', {:email => 'hat@bat.com', :stories => [4, 1]}, accept_header    
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid_flex
    put '/surveys/0.xml', {:email => 'hat@bat.com', :stories => [4, 1]}, flex_header
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end
end