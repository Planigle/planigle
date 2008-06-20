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
    get :new, :project_id => 1, :survey_key => projects(:first).survey_key
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
    get :new, :project_id => 1, :id => 0
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    post :create, :project_id => 1, :survey_key => projects(:first).survey_key, :name => 'hat', :email => 'hat@bat.com', :stories => [4, 1]
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    post :create, :project_id => 1, :survey_key => projects(:first).survey_key, :stories => [4, 1]
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    post :create, :project_id => 1, :survey_key => 0, :email => 'hat@bat.com', :stories => [4, 1]
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test listing surveys.
  def test_list_survey_unauthorized
    get :index, :project_id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test listing surveys.
  def test_list_survey
    login_as(individuals(:quentin))
    get :index, :project_id => 1
    assert_response :success

    assert_select 'surveys' do
      assert_select 'survey', 3 do
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
    get :show, :project_id => 1, :id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'        
  end

  # Test showing a survey.
  def test_show_survey
    login_as(individuals(:quentin))
    get :show, :project_id => 1, :id => 1
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
    login_as(individuals(:quentin))
    put :update, :project_id => 1, :id => 2, :record => {:excluded => "true"}
    assert_response :success
    assert_select 'survey'
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid
    login_as(individuals(:quentin))
    put :update, :project_id => 1, :id => 0, :record => {:excluded => "true"}
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized
    put :update, :project_id => 1, :id => 2, :record => {:excluded => "true"}
    assert_redirected_to :controller => 'sessions', :action => 'new'        
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end
end