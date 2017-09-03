require "#{File.dirname(__FILE__)}/../test_helper"

class SurveysControllerTest < ActionDispatch::IntegrationTest
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :releases
  fixtures :teams
  fixtures :iterations
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

  # Test creating a survey.
  def test_create_survey
    get base_URL + '/new', params: {:survey_key => projects(:first).survey_key}
    assert_response :success

    assert_equal 2, json.length
  end

  # Test creating a survey w/ invalid number.
  def test_create_survey_invalid
    get base_URL + '/new', params: {:survey_key => 55555}
    assert_response 422
    assert json['error']
  end

  # Test creating a survey w/ a community edition account.
  def test_create_survey_community
    get base_URL + '/new', params: {:survey_key => projects(:second).survey_key}
    assert_response 422
    assert json['error']
  end

  # Test submitting a survey.
  def test_submit_survey_success
    count = Story.count
    post base_URL, params: {record: {:survey_key => projects(:first).survey_key, :name => 'hat', :email => 'hat@bat.com', :stories => [4, 1, "try,this"]}}
    assert_response :success

    assert_equal (BigDecimal("4")/3).round(3), stories(:first).reload.user_priority
    assert_equal BigDecimal("1"), stories(:second).reload.user_priority
    assert_equal BigDecimal("2"), stories(:third).reload.user_priority
    assert_equal BigDecimal("1"), stories(:fourth).reload.user_priority
    assert_equal count+1, Story.count
    assert_equal BigDecimal("3"), Story.where(:name => 'User suggestion: try', :description => "Suggested by hat (hat@bat.com)\rthis").first.user_priority
  end

  # Test submitting a survey unsuccessfully.
  def test_submit_survey_failure
    post base_URL, params: {record: {:survey_key => projects(:first).survey_key, :stories => [4, 1]}}
    assert_response 422
    assert json['name'] # can't be blank
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ an invalid survey number.
  def test_submit_survey_invalid
    post base_URL, params: {record: {:survey_key => 0, :email => 'hat@bat.com', :stories => [4, 1]}}
    assert_response 422
    assert json['error']
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test submitting a survey w/ a community edition account.
  def test_submit_survey_community
    post base_URL, params: {record: {:survey_key => projects(:second).survey_key, :email => 'hat@bat.com', :stories => [4, 1]}}
    assert_response 422
    assert json['error']
    assert_nil stories(:fourth).reload.user_priority
  end

  # Test listing surveys.
  def test_list_survey_unauthorized
    get base_URL
    assert_response 401
  end

  # Test listing surveys.
  def test_list_survey
    login_as(individuals(:quentin))
    get base_URL
    assert_response :success
    assert Survey.count, json.length
  end

  # Test showing a survey.
  def test_show_survey_unauthorized
    get base_URL + '/1'
    assert_response 401
  end

  # Test showing a survey.
  def test_show_survey
    login_as(individuals(:quentin))
    get base_URL + '/1'
    assert_response :success
    survey = json
    assert survey['id']
    assert survey['name']
    assert_nil survey['company']
    assert survey['email']
    assert survey['excluded'] != nil
    assert survey['survey_mappings']
    survey_mapping = survey['survey_mappings'][0]
    assert survey_mapping['story_id']
    assert survey_mapping['priority']
    assert survey_mapping['name']
    assert survey_mapping['description']
    assert survey_mapping['normalized_priority']
  end

  # Test updating a survey.
  def test_update_survey
    login_as(individuals(:quentin))
    put base_URL + '/2', params: {:record => {:excluded => "true"}}
    assert_response :success
    assert json
    assert surveys(:second).reload.excluded
    assert_nil stories(:third).reload.user_priority
  end

  # Test updating a survey w/ invalid number.
  def test_update_survey_invalid
    login_as(individuals(:quentin))
    put base_URL + '/0', params: {:record => {:excluded => "true"}}
    assert_response 404
    assert_equal 2.0, stories(:third).reload.user_priority
  end

  # Test updating a survey w/o authorization.
  def test_update_survey_unauthorized
    put base_URL + '/2', params: {:record => {:excluded => "true"}}
    assert_response 401
    assert !surveys(:second).reload.excluded
    assert_equal 2.0, stories(:third).reload.user_priority
  end
    
  # Test getting surveys (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Survey.count)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Survey.where(project_id: 1).length)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Survey.where(project_id: 1).length)
  end
    
  # Test getting surveys (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Survey.where(project_id: 1).length)
  end

  # Test getting surveys (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a survey for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/4'
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
    put base_URL + '/4', params: {:record => {:excluded => 'true'}}
    assert_response 401
    assert_equal false, surveys(:fourth).reload.excluded
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user )
    login_as(user)
    put base_URL + '/1', params: {:record => {:excluded => 'true'}}
    assert_response :success
    assert surveys(:first).reload.excluded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user )
    login_as(user)
    put base_URL + '/1', params: {:record => {:excluded => 'true'}}
    assert_response 401
    assert_equal false, surveys(:first).reload.excluded
    assert json['error']
  end
  
private

  def json
    JSON.parse(response.body)
  end
  
  def base_URL
    '/planigle/api/surveys'
  end
end