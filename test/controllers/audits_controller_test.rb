require "#{File.dirname(__FILE__)}/../test_helper"

class AuditsControllerTest < ActionDispatch::IntegrationTest
  fixtures :systems
  fixtures :individuals
  fixtures :audits
  fixtures :projects
  fixtures :individuals_projects
  fixtures :audits

  def test_index_unauthorized
    get base_URL
    assert_response 401
  end
    
  # Test successfully getting a listing of resources.
  def test_index_success
    login_as(individuals(:quentin))
    get base_URL
    assert_response :success
    assert 6, json.length
  end
    
  # Test successfully getting a listing of audits by object id.
  def test_index_object_id
    login_as(individuals(:quentin))
    get base_URL, params: {:object_id => 1, :type => 'Story'}
    assert_response :success
    assert 2, json.length
  end
    
  # Test successfully getting a listing of audits by user id.
  def test_index_user_id
    login_as(individuals(:quentin))
    get base_URL, params: {:user_id => 2}
    assert_response :success
    assert 4, json.length
  end
    
  # Test successfully getting a listing of audits by start.
  def test_index_start
    login_as(individuals(:quentin))
    get base_URL, params: {:start => '2008-11-03'}
    assert_response :success
    assert 4, json.length
  end
    
  # Test successfully getting a listing of audits by end.
  def test_index_end
    login_as(individuals(:quentin))
    get base_URL, params: {:end => '2008-11-03'}
    assert_response :success
    assert 3, json.length
  end
    
  # Test successfully getting a listing of audits by type.
  def test_index_type
    login_as(individuals(:quentin))
    get base_URL, params: {:type => 'Story'}
    assert_response :success
    assert 5, json.length
  end

  # Test showing an resource without credentials.
  def test_show_unauthorized
    get base_URL + '/1'
    assert_response 401
  end
    
  # Test successfully showing a resource.
  def test_show_success
    login_as(individuals(:quentin))
    get base_URL + '/1'
    assert_response :success
    assert json
  end
    
  # Test unsuccessfully showing a resource.
  def test_show_not_found
    login_as(individuals(:quentin))
    get base_URL + '/999'
    assert_response 404
  end

  # Test getting audits (based on role).
  def test_index_by_admin
    index_by_role(individuals(:quentin), Audited::Audit.count)
  end
    
  # Test getting audits (based on role).
  def test_index_by_project_admin
    index_by_role(individuals(:aaron), Audited::Audit.where(project_id: 1).length)
  end
    
  # Test getting audits (based on role).
  def test_index_by_project_user
    index_by_role(individuals(:user), Audited::Audit.where(project_id: 1).length)
  end
    
  # Test getting audits (based on role).
  def test_index_by_read_only_user
    index_by_role(individuals(:readonly), Audited::Audit.where(project_id: 1).length)
  end

  # Test getting audits (based on role).
  def index_by_role(user, count)
    login_as(user)
    get base_URL
    assert_response :success
    assert count, json.length
  end

  # Test showing an audit for another project.
  def test_show_wrong_project
    login_as(individuals(:aaron))
    get base_URL + '/6'
    assert_response 401
  end
  
private

  def json
    JSON.parse(response.body)
  end
  
  def base_URL
    '/audits'
  end
end