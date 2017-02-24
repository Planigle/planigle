require "base64"

module ResourceHelper
  # Test the get /resources request without credentials.
  def test_index_unauthorized
    get resource_url, params: {}, headers: accept_header
    assert_response 401 # Unauthorized
  end

  # Test a successful get /resources request.
  def test_index_success
    get resource_url, params: {}, headers: authorization_header
    assert_response :success
    assert_select resources_string do
      assert_select resource_string, :count => resource_count
    end
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
    num = resource_count
    post resource_url, params: create_success_parameters, headers: authorization_header
    assert_response 201 # Created
    assert_select resource_string
    assert_create_succeeded
    assert_equal num + 1, resource_count
  end

  # Test a failed post /resources request.
  def test_create_failure
    num = resource_count
    post resource_url, params: create_failure_parameters, headers: authorization_header
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
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
    get resource_url << '/1', params: {}, headers: authorization_header
    assert_response :success
    assert_select resource_string
  end

  # Test a failed get /resources/id request.
  def test_show_not_found
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
    put resource_url << '/1', params: update_success_parameters, headers: authorization_header
    assert_response 200 # Success
    assert_update_succeeded
  end

  # Test a failed put /resources/id request.
  def test_update_failure
    put resource_url << '/1', params: update_failure_parameters, headers: authorization_header
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_change_failed
  end

  # Test a failed (not found) put /resources/id request.
  def test_update_not_found
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
    delete resource_url << '/2', params: {}, headers: authorization_header
    assert_response 200 # Success
    assert_delete_succeeded
  end

  # Test a failed delete /resources/id request.
  def test_destroy_failure
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
end