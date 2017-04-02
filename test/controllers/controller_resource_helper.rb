module ControllerResourceHelper
  # Test getting a listing of resources without credentials.
  def test_index_unauthorized
    get base_URL, params: context
    assert_response 401
  end
    
  # Test successfully getting a listing of resources.
  def test_index_success
    login_as(individuals(:quentin))
    get base_URL, params: context
    assert_response :success
  end

  # Test creating a new resource without credentials.
  def test_create_unauthorized
    num = full_resource_count
    post base_URL, params: create_success_parameters
    assert_response 401
    assert_equal num, full_resource_count
    assert_change_failed
  end

  # Test successfully creating a new resource.
  def test_create_success
    login_as(individuals(:quentin))
    num = full_resource_count
    post base_URL, params: create_success_parameters
    assert_equal num + 1, full_resource_count
    assert_create_succeeded
  end

  # Test creating a new resource unsuccessfully.
  def test_create_failure
    login_as(individuals(:quentin))
    num = full_resource_count
    post base_URL, params: create_failure_parameters
    assert_response 422
    assert_equal num, full_resource_count
    assert_change_failed
  end
  
  def full_resource_count
    resource_count
  end

  # Test showing an resource without credentials.
  def test_show_unauthorized
    get base_URL + '/1', params: context
    assert_response 401
  end
    
  # Test successfully showing a resource.
  def test_show_success
    login_as(individuals(:quentin))
    get base_URL + '/1', params: context
    assert_response :success
    assert_not_nil json
  end
    
  # Test unsuccessfully showing a resource.
  def test_show_not_found
    login_as(individuals(:quentin))
    get base_URL + '/999', params: context
    assert_response 404
  end

  # Test updating an resource without credentials.
  def test_update_unauthorized
    put base_URL + '/1', params: update_success_parameters
    assert_response 401
    assert_change_failed
  end

  # Test succcessfully updating an resource.
  def test_update_success
    login_as(individuals(:quentin))
    put base_URL + '/1', params: update_success_parameters
    assert_response :success
    assert_update_succeeded
  end

  # Test updating an resource where the update fails.
  def test_update_failure
    login_as(individuals(:quentin))
    put base_URL + '/1', params: update_failure_parameters
    assert_response 422
    assert_change_failed
  end

  # Test unsucccessfully (not found) updating an resource.
  def test_update_not_found
    login_as(individuals(:quentin))
    put base_URL + '/999', params: update_success_parameters
    assert_response 404
  end

  # Test deleting an resource without credentials.
  def test_destroy_unauthorized
    delete base_URL + '/2', params: context
    assert_response 401
    assert_delete_failed
  end
    
  # Test successfully deleting a resource.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete base_URL + '/2', params: context
    assert_response :success
    assert_delete_succeeded
  end
    
  # Test unsuccessfully (not found) deleting a resource.
  def test_destroy_not_found
    login_as(individuals(:quentin))
    delete base_URL + '/999', params: context
    assert_response 404
  end
  
  def json
    JSON.parse(response.body)
  end
      
private

  # Answer a symbol for the resource.
  def resource_symbol
    :record
  end
end