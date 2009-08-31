require "#{File.dirname(__FILE__)}/../test_helper"
require "surveys_controller"

# Re-raise errors caught by the controller.
class SurveysController; def rescue_action(e) raise e end; end

class SurveysControllerTest < ActionController::TestCase

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

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

  # Test creating a survey w/ a community edition account.
  def test_create_survey_community
    get :new, :project_id => 1, :id => 0, :survey_key => projects(:second).survey_key
    assert_response :success

    assert_select 'errors' do
      assert_select 'error'
    end
  end

  # Test submitting a survey.
  def test_submit_survey_success
    count = Story.count
    post :create, :project_id => 1, :survey_key => projects(:first).survey_key, :name => 'hat', :email => 'hat@bat.com', :stories => [4, 1, "try,this"]
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
    assert_equal count+1, Story.count
    assert_equal BigDecimal("3"), Story.find(:first, :conditions => {:name => 'User suggestion: try', :description => "Suggested by hat (hat@bat.com)\rthis"}).user_priority
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

  # Test submitting a survey w/ a community edition account.
  def test_submit_survey_community
    post :create, :project_id => 1, :survey_key => projects(:second).survey_key, :email => 'hat@bat.com', :stories => [4, 1]
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
    
  # Test getting surveys (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Survey.count)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Survey.find_all_by_project_id(1).length)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Survey.find_all_by_project_id(1).length)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Survey.find_all_by_project_id(1).length)
  end

  # Test getting surveys (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml'
    assert_response :success
    assert_select "surveys" do
      assert_select "survey", count
    end
  end

  # Test showing a survey for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 4, :format => 'xml'
    assert_response 401
  end
    
  # Test updating surveys (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
    
  # Test updating surveys (based on role).
  def test_update_by_project_user
    update_by_role_unsuccessful(individuals(:user))
  end
    
  # Test updating surveys (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a survey for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put :update, :id => 4, :format => 'xml', :record => {:excluded => 'true'}
    assert_response 401
    assert_equal false, surveys(:fourth).reload.excluded
    assert_select 'errors'
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user )
    login_as(user)
    put :update, :id => 1, :format => 'xml', :record => {:excluded => 'true'}
    assert_response :success
    assert surveys(:first).reload.excluded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put :update, :id => 1, :format => 'xml', :record => {:excluded => 'true'}
    assert_response 401
    assert_equal false, surveys(:first).reload.excluded
    assert_select "errors"
  end
end