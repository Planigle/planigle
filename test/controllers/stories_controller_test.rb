require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../stories_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "bigdecimal"
require "notification/test_notifier"
require "stringio"

class StoriesControllerTest < ActionDispatch::IntegrationTest
  include ControllerResourceHelper
  include StoriesTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :teams
  fixtures :individuals
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :projects
  fixtures :individuals_projects
  fixtures :tasks
  fixtures :criteria
  fixtures :surveys
  fixtures :survey_mappings

  # Test splitting a story without credentials.
  def test_split_put_unauthorized
    num = resource_count
    post base_URL + '/split/1', params: {resource_symbol => (create_success_parameters[resource_symbol])} # hack to get around compiler issue
    assert_response 401
    assert_equal num, resource_count    
  end

  # Test splitting a story successfully.
  def test_split_put_success
    num = resource_count
    login_as(individuals(:quentin))
    params = create_success_parameters
    params[resource_symbol]['acceptance_criteria'] = 'criteria'
    post base_URL + '/split/1', params: {resource_symbol => (params[resource_symbol])} # hack to get around compiler issue
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    assert_equal 1, stories(:first).criteria.count
    split = Story.where(name: 'foo').first
    assert_equal 1, split.tasks.count
    assert_equal 1, split.criteria.count
  end

  # Test splitting a story unsuccessfully.
  def test_split_put_failure
    num = resource_count
    login_as(individuals(:quentin))
    post base_URL + '/split/1', params: {resource_symbol => (create_failure_parameters[resource_symbol])} # hack to get around compiler issue
    assert_response 422
    assert_equal num, resource_count
    assert_change_failed
  end
  
  # Test successfully setting the iteration.
  def test_set_iteration_success
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:iteration_id => 2}}
    assert_response :success
    assert_equal stories(:first).reload.iteration_id, 2
  end
  
  # Test unsuccessfully setting the iteration.
  def test_set_iteration_failure
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:iteration_id => 999}}
    assert_response 422
    assert_not_equal stories(:first).reload.iteration_id, 999
  end
  
  # Test successfully setting the owner.
  def test_set_owner_success
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:individual_id => 2}}
    assert_response :success
    assert_equal stories(:first).reload.individual_id, 2
  end
  
  # Test unsuccessfully setting the owner.
  def test_set_owner_failure
    login_as(individuals(:quentin))
    put base_URL + '/1', params: {:record => {:individual_id => 999}}
    assert_response 422
    assert_not_equal stories(:first).reload.individual_id, 999
  end
    
  # Test that changing from accepted to created or in progress recalculates surveys.
  def test_status_code_change
    assert_equal 2, stories(:first).user_priority
    login_as(individuals(:quentin))

    put base_URL + '/2', params: {:record => {:status_code => 0}}
  
    # Rounded to 1000th place to eliminate trivial differences
    assert_equal BigDecimal("1.5"), stories(:first).reload.user_priority
    
    put base_URL + '/2', params: {:record => {:status_code => 1}}
    assert_equal BigDecimal("1.5"), stories(:first).reload.user_priority
  end

  # Test changing the status to blocked.
  def test_change_to_blocked_not_premium
    notification_count = ::Notification::TestNotifier.number_of_notifications
    login_as(individuals(:user2))
    put base_URL + '/5', params: {:record => {:status_code => 2}}
    assert_equal notification_count, ::Notification::TestNotifier.number_of_notifications
  end

  # Test changing the status to blocked.
  def test_change_to_blocked_premium_team
    notification_count = ::Notification::TestNotifier.number_of_notifications
    login_as(individuals(:aaron))
    put base_URL + '/1', params: {:record => {:status_code => 2}}
    assert_equal notification_count + 4, ::Notification::TestNotifier.number_of_notifications
  end

  # Test changing the status to done.
  def test_change_to_done_premium_team
    notification_count = ::Notification::TestNotifier.number_of_notifications
    login_as(individuals(:aaron))
    put base_URL + '/1', params: {:record => {:status_code => 3}}
    assert_equal notification_count + 4, ::Notification::TestNotifier.number_of_notifications
  end

  # Test changing the status to blocked.
  def test_change_to_blocked_premium_no_team
    notification_count = ::Notification::TestNotifier.number_of_notifications
    login_as(individuals(:aaron))
    put base_URL + '/2', params: {:record => {:status_code => 2}}
    assert_equal notification_count + 4, ::Notification::TestNotifier.number_of_notifications
  end

  # Test exporting stories (based on role).
  def test_export_by_admin
    export_by_role(individuals(:quentin), 0)
  end
    
  # Test exporting stories (based on role).
  def test_export_by_project_admin
    export_by_role(individuals(:aaron), Story.where(project_id: 1).length + 2) # 2 tasks
  end

  # Test exporting stories (based on role).
  def test_export_by_project_user
    export_by_role(individuals(:user), Story.where(project_id: 1).length + 2)
  end

  # Test exporting stories (based on role).
  def test_export_by_readonly
    export_by_role(individuals(:readonly), Story.where(project_id: 1).length + 2)
  end

  # Test exporting stories (based on role).
  def export_by_role(user, count)
    login_as(user)
    get base_URL + '/export'
    assert_response :success
    assert_equal count+1, @response.body.split("\n").length
  end

  # Test importing stories (based on role).
  def test_import_by_admin
    import_by_role(individuals(:quentin), true)
  end
    
  # Test importing stories (based on role).
  def test_import_by_project_admin
    import_by_role(individuals(:aaron), true)
  end

  # Test importing stories (based on role).
  def test_import_by_project_user
    import_by_role(individuals(:user), true)
  end

  # Test importing stories (based on role).
  def test_import_by_readonly_user
    import_by_role(individuals(:readonly), false)
  end

  # Test importing stories (based on role).
  def import_by_role(user, success)
    name = stories(:first).name
    login_as(user)
    post base_URL + '/import', params: {:Filedata => "PID,name\n1,Foo"}
    if success
      assert_response :success
      assert_equal 'Foo', stories(:first).reload.name
    else
      assert_response 422
      assert json['error']
      assert_equal name, stories(:first).reload.name
    end
  end

  # Test importing stories to wrong project.
  def test_import_wrong_project
    name = stories(:fifth).name
    login_as(individuals(:user))
    post base_URL + '/import', params: {:Filedata => "PID,name\n5,Foo"}
    assert_response 422
    assert json['error']
    assert_equal name, stories(:fifth).reload.name
  end

  # Test getting stories (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), 0)
  end
    
  # Test getting stories (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Story.where(project_id: 1).length - 1)
  end
    
  # Test getting stories (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Story.where(project_id: 1).length - 1)
  end
    
  # Test getting stories (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Story.where(project_id: 1).length - 1)
  end
    
  # Test getting stories (based on role).
  def index_by_role(user, count, params={})
    login_as(user)
    get base_URL, params: params
    assert_response :success
    assert_equal count, json.length
  end

  # Test showing a story for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/5'
    assert_response 401
  end
    
  # Test creating stories (based on role).
  def test_create_by_project_admin
    create_by_role_successful(individuals(:aaron))
  end
    
  # Test creating stories (based on role).
  def test_create_by_project_user
    create_by_role_successful(individuals(:user))
  end
    
  # Test creating stories (based on role).
  def test_create_by_read_only_user
    create_by_role_unsuccessful(individuals(:readonly))
  end

  # Test creating a story for another project.
  def test_create_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters
    params[:record] = params[:record].merge( :project_id => '2' )
    post base_URL, params: params
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end

  # Create successfully based on role.
  def create_by_role_successful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
  end    
  
  # Create unsuccessfully based on role.
  def create_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    post base_URL, params: create_success_parameters
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end    
    
  # Test splitting stories (based on role).
  def test_split_by_project_admin
    split_by_role_successful(individuals(:aaron))
  end
    
  # Test splitting stories (based on role).
  def test_split_by_project_user
    split_by_role_successful(individuals(:user))
  end
    
  # Test creating stories (based on role).
  def test_split_by_read_only_user
    split_by_role_unsuccessful(individuals(:readonly))
  end

  # Test splitting a story for another project.
  def test_split_wrong_project
    login_as(individuals(:aaron))
    num = resource_count
    params = create_success_parameters
    params[:record] = params[:record].merge( :project_id => '2' )
    post base_URL + '/split/1', params: params
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end

  # Split successfully based on role.
  def split_by_role_successful( user )
    login_as(user)
    num = resource_count
    params = create_success_parameters
    params[resource_symbol]['acceptance_criteria'] = 'criteria'
    post base_URL + '/split/1', params: params
    assert_response 201
    assert_equal num + 1, resource_count
    assert_create_succeeded
    assert_equal 1, stories(:first).tasks.count
    assert_equal 1, stories(:first).criteria.count
    split = Story.where(name: 'foo').first
    assert_equal 1, split.tasks.count
    assert_equal 1, split.criteria.count
  end    
  
  # Split unsuccessfully based on role.
  def split_by_role_unsuccessful( user )
    login_as(user)
    num = resource_count
    post base_URL + '/split/1', params: create_success_parameters
    assert_response 401
    assert_equal num, resource_count
    assert json['error']
  end

  # Test updating stories (based on role).
  def test_update_by_project_admin
    update_by_role_successful(individuals(:aaron))
  end
  
  # Test changing project.
  def test_update_project_by_project_admin
    update_by_role_successful(individuals(:aaron), update_success_parameters[resource_symbol].merge({:project_id => 3, :release_id => nil, :iteration_id => nil, :team_id => nil, :individual_id => nil}))
  end
    
  # Test updating stories (based on role).
  def test_update_by_project_user
    update_by_role_successful(individuals(:user))
  end
  
  # Test changing project.
  def test_update_project_by_project_user
    update_by_role_unsuccessful(individuals(:user), update_success_parameters[resource_symbol].merge({:project_id => 3, :release_id => nil, :iteration_id => nil, :team_id => nil, :individual_id => nil}))
  end
    
  # Test updating stories (based on role).
  def test_update_by_read_only_user
    update_by_role_unsuccessful(individuals(:readonly))
  end
    
  # Test updating a story for another project.
  def test_update_wrong_project
    login_as(individuals(:aaron))
    put base_URL + '/5', params: update_success_parameters
    assert_response 401
    assert_change_failed
    assert json['error']
  end
  
  # Update successfully based on role.
  def update_by_role_successful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put base_URL + '/2', params: {resource_symbol => params}
    assert_response :success
    assert_update_succeeded
  end
    
  # Update unsuccessfully based on role.
  def update_by_role_unsuccessful( user, params = (update_success_parameters[resource_symbol]) )
    login_as(user)
    put base_URL + '/1', params: {resource_symbol => params}
    assert_response 401
    assert_change_failed
    assert json['error']
  end    
    
  # Test deleting stories (based on role).
  def test_delete_by_project_admin
    delete_by_role_successful(individuals(:aaron))
  end
    
  # Test deleting stories (based on role).
  def test_delete_by_project_user
    delete_by_role_successful(individuals(:user))
  end
    
  # Test deleting stories (based on role).
  def test_delete_by_read_only_user
    delete_by_role_unsuccessful(individuals(:readonly))
  end
  
  # Delete from a different project.
  def test_delete_wrong_project
    login_as(individuals(:aaron))
    delete base_URL + '/5'
    assert_response 401
    assert Story.where(name: 'test5').first
    assert json['error']
  end
      
  # Delete successfully based on role.
  def delete_by_role_successful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response :success
    assert_nil Story.where(name: 'test1').first
  end

  # Delete unsuccessfully based on role.
  def delete_by_role_unsuccessful( user )
    login_as(user)
    delete base_URL + '/1'
    assert_response 401
    assert Story.where(name: 'test').first
    assert json['error']
  end
    
  def test_story_filtered_out
    login_as(individuals(:aaron))
    get base_URL, params: {:conditions => {:status_code => 1}}
    put base_URL + '/1', params: {:record => {:status_code => 2}}
  end
  
  def test_task_filtered_out
    login_as(individuals(:aaron))
    get base_URL, params: {:conditions => {:status_code => 1}}
    put base_URL + '/1', params: {:record => {}}
  end
end