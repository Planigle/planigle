require "base64"

module ResourceHelper
  # Test the get /resources request without credentials.
  def test_index_unauthorized
    get resource_url, params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test a successful get /resources request.
  def test_index_success
    login_as(individuals(:admin2))
    get resource_url, params: {}, headers: authorization_header
    assert_response :success
    assert_equal resource_count, json.length
  end

  # Test the post /resources request.
  def test_create_unauthorized
    num = resource_count
    post resource_url, params: create_success_parameters, headers: accept_header
    assert_response 401 # Unauthorized
    assert_equal num, resource_count
    assert_valid_change_failed
  end

  # Test a successful post /resources request.
  def test_create_success
    login_as(individuals(:admin2))
    num = resource_count
    post resource_url, params: create_success_parameters, headers: authorization_header
    assert_response 201 # Created
    assert  json
    assert_create_succeeded
    assert_equal num + 1, resource_count
  end

  # Test a failed post /resources request.
  def test_create_failure
    login_as(individuals(:admin2))
    num = resource_count
    post resource_url, params: create_failure_parameters, headers: authorization_header
    assert_response 422 # Unprocessable Entity
    assert json
    assert_change_failed
    assert_equal num, resource_count
  end

  # Test the get /resources/id request without credentials.
  def test_show_unauthorized
    get resource_url << '/1', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test a successful get /resources/id request.
  def test_show_success
    login_as(individuals(:admin2))
    get resource_url << '/1', params: {}, headers: authorization_header
    assert_response :success
    assert json
  end

  # Test a failed get /resources/id request.
  def test_show_not_found
    login_as(individuals(:admin2))
    get resource_url << '/999', params: {}, headers: authorization_header
    assert_response 404
  end
  
  # Test the put /resources/id request without credentials.
  def test_update_unauthorized
    put resource_url << '/1', params: update_success_parameters, headers: accept_header
    assert_response 401 # Unauthorized
    assert_valid_change_failed
  end

  # Test a successful put /resources/id request.
  def test_update_success
    login_as(individuals(:admin2))
    put resource_url << '/1', params: update_success_parameters, headers: authorization_header
    assert_response 200 # Success
    assert_update_succeeded
  end

  # Test a failed put /resources/id request.
  def test_update_failure
    login_as(individuals(:admin2))
    put resource_url << '/1', params: update_failure_parameters, headers: authorization_header
    assert_response 422 # Unprocessable Entity
    assert json
    assert_change_failed
  end

  # Test a failed (not found) put /resources/id request.
  def test_update_not_found
    login_as(individuals(:admin2))
    put resource_url << '/999', params: update_success_parameters, headers: authorization_header
    assert_response 404 # Not found
    assert_change_failed
  end
  
  # Test the delete /resources/id request without credentials.
  def test_destroy_unauthorized
    delete resource_url << '/2', params: {}, headers: accept_header
    assert_response 401 # Unauthorized
    assert_delete_failed
  end

  # Test a successful delete /resources/id request.
  def test_destroy_success
    login_as(individuals(:admin2))
    delete resource_url << '/2', params: {}, headers: authorization_header
    assert_response 200 # Success
    assert_delete_succeeded
  end

  # Test a failed delete /resources/id request.
  def test_destroy_failure
    login_as(individuals(:admin2))
    delete resource_url << '/999', params: {}, headers: authorization_header
    assert_response 404 # Does not exist
  end
  
private

  # Return the url to get the resource (ex., resources)
  def resource_url
    '/' << resources_string
  end

  # Return the string representing the resource plural form (ex., resources)
  def resources_string
    object_type.downcase
  end

  # Return the string representing the resource singular form (ex., resource)
  def resource_string
    resources_string.singularize
  end

  # Answer a string representing the type of object. Ex., Story.
  def object_type
    self.class.to_s.chomp('IntegrationTest')
  end
    
  def json
    JSON.parse(response.body)
  end
end