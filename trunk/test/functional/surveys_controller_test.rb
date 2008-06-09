require "#{File.dirname(__FILE__)}/../test_helper"
require "surveys_controller"

# Re-raise errors caught by the controller.
class SurveysController; def rescue_action(e) raise e end; end

class SurveysControllerTest < Test::Unit::TestCase

  fixtures :individuals
  fixtures :projects
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

  def setup
    @controller = SurveysController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test creating a survey.
  def test_create_survey
    get :show, :id => projects(:first).survey_key
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
    get :show, :id => 0
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    put :update, :id => projects(:first).survey_key, :email => 'hat@bat.com', :stories => [4, 1]
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    put :update, :id => projects(:first).survey_key, :stories => [4, 1]
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    put :update, :id => 0, :email => 'hat@bat.com', :stories => [4, 1]
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end
end