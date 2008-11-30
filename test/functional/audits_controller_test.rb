require "#{File.dirname(__FILE__)}/../test_helper"
require "audits_controller"

# Re-raise errors caught by the controller.
class AuditsController; def rescue_action(e) raise e end; end

class AuditsControllerTest < ActionController::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :audits
  fixtures :projects
  fixtures :audits

  def test_index_unauthorized
    get :index, {}
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting a listing of resources.
  def test_index_success
    login_as(individuals(:quentin))
    get :index, {}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 6
    end
  end
    
  # Test successfully getting a listing of audits by object id.
  def test_index_object_id
    login_as(individuals(:quentin))
    get :index, {:object_id => 1, :type => 'Story'}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 2
    end
  end
    
  # Test successfully getting a listing of audits by user id.
  def test_index_user_id
    login_as(individuals(:quentin))
    get :index, {:user_id => 2}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 4
    end
  end
    
  # Test successfully getting a listing of audits by start.
  def test_index_start
    login_as(individuals(:quentin))
    get :index, {:start => '2008-11-03'}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 4
    end
  end
    
  # Test successfully getting a listing of audits by end.
  def test_index_end
    login_as(individuals(:quentin))
    get :index, {:end => '2008-11-03'}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 3
    end
  end
    
  # Test successfully getting a listing of audits by type.
  def test_index_type
    login_as(individuals(:quentin))
    get :index, {:type => 'Story'}
    assert_response :success
    assert_select 'audits' do
      assert_select 'audit', 5
    end
  end

  # Test showing an resource without credentials.
  def test_show_unauthorized
    get :show, {:id => 1}
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully showing a resource.
  def test_show_success
    login_as(individuals(:quentin))
    get :show, {:id => 1}
    assert_response :success
    assert_select 'audit'
  end
    
  # Test unsuccessfully showing a resource.
  def test_show_not_found
    login_as(individuals(:quentin))
    get :show, {:id => 999}
    assert_response 404
  end

  # Test getting audits (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Audit.count)
  end
    
  # Test getting audits (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Audit.find_all_by_project_id(1).length)
  end
    
  # Test getting audits (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Audit.find_all_by_project_id(1).length)
  end
    
  # Test getting audits (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Audit.find_all_by_project_id(1).length)
  end

  # Test getting audits (based on role).
  def index_by_role(user, count)
    login_as(user)
    get :index, :format => 'xml'
    assert_response :success
    assert_select "audits" do
      assert_select "audit", count
    end
  end

  # Test showing an audit for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get :show, :id => 6, :format => 'xml'
    assert_response 401
  end
end