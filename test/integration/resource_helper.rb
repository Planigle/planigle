require "base64"

module ResourceHelper
  # Test the get /resources request without credentials.
  def test_index_unauthorized
    get resource_url, {}, accept_header
    assert_response 401 # Unauthorized
  end

  # Test the get /resources request without credentials from Flex.
  def test_index_unauthorized_flex
    get resource_url << '.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end

  # Test a successful get /resources request.
  def test_index_success
    get resource_url, {}, authorization_header
    assert_response :success
    assert_select resources_string do
      assert_select resource_string, :count => resource_count
    end
  end

  # Test a successful get /resources request from Flex.
  def test_index_success_flex
    flex_login
    get resource_url << '.xml', {}, flex_header
    assert_response :success
    assert_select resources_string do
      assert_select resource_string, :count => resource_count 
    end
  end

  # Test the post /resources request.
  def test_create_unauthorized
    num = resource_count
    post resource_url, create_success_parameters, accept_header
    assert_response 401 # Unauthorized
    assert_equal num, resource_count
    assert_valid_change_failed
  end

  # Test the post /resources request from Flex.
  def test_create_unauthorized_flex
    num = resource_count
    post resource_url << '.xml', create_success_parameters, flex_header
    assert_response 401 # Unauthorized
    assert_equal num, resource_count
    assert_valid_change_failed
  end

  # Test a successful post /resources request.
  def test_create_success
    num = resource_count
    post resource_url, create_success_parameters, authorization_header
    assert_response 201 # Created
    assert_select resource_string
    assert_create_succeeded
    assert_equal num + 1, resource_count
  end

  # Test a successful post /resources request from Flex.
  def test_create_success_flex
    num = resource_count
    flex_login
    post resource_url << '.xml', create_success_parameters, flex_header
    assert_response 200 # OK
    assert_select resource_string
    assert_create_succeeded
    assert_equal num + 1, resource_count
  end

  # Test a failed post /resources request.
  def test_create_failure
    num_individuals = resource_count
    post resource_url, create_failure_parameters, authorization_header
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_change_failed
    assert_equal num_individuals, resource_count
  end

  # Test a failed post /resources request from Flex.
  def test_create_failure_flex
    num = resource_count
    flex_login
    post resource_url << '.xml', create_failure_parameters, flex_header
    assert_response 200 # OK
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_change_failed
    assert_equal num, resource_count
  end

  # Test the get /resources/id request without credentials.
  def test_show_unauthorized
    get resource_url << '/1', {}, accept_header
    assert_response 401 # Unauthorized
  end

  # Test the get /resources/id request without credentials from Flex.
  def test_show_unauthorized_flex
    get resource_url << '/1.xml', {}, flex_header
    assert_response 401 # Unauthorized
  end

  # Test a successful get /resources/id request.
  def test_show_success
    get resource_url << '/1', {}, authorization_header
    assert_response :success
    assert_select resource_string
  end

  # Test a successful get /resources/id request from Flex.
  def test_show_success_flex
    flex_login
    get resource_url << '/1.xml', {}, flex_header
    assert_response :success
    assert_select resource_string
  end

  # Test a failed get /resources/id request.
  def test_show_not_found
    get resource_url << '/999', {}, authorization_header
    assert_response 404
  end

  # Test a failed get /resources/id request from Flex.
  def test_show_not_found_flex
    flex_login
    get resource_url << '/999.xml', {}, flex_header
    assert_response 404
  end
  
  # Test the put /resources/id request without credentials.
  def test_update_unauthorized
    put resource_url << '/1', update_success_parameters, accept_header
    assert_response 401 # Unauthorized
    assert_valid_change_failed
  end
  
  # Test the put /resources/id request without credentials from Flex.
  def test_update_unauthorized_flex
    put resource_url << '/1.xml', update_success_parameters, flex_header
    assert_response 401 # Unauthorized
    assert_valid_change_failed
  end

  # Test a successful put /resources/id request.
  def test_update_success
    put resource_url << '/1', update_success_parameters, authorization_header
    assert_response 200 # Success
    assert_update_succeeded
  end

  # Test a successful put /resources/id request from Flex.
  def test_update_success_flex
    flex_login
    put resource_url << '/1.xml', update_success_parameters, flex_header
    assert_response 200 # Success
    assert_update_succeeded
  end

  # Test a failed put /resources/id request.
  def test_update_failure
    put resource_url << '/1', update_failure_parameters, authorization_header
    assert_response 422 # Unprocessable Entity
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_change_failed
  end

  # Test a failed put /resources/id request from Flex.
  def test_update_failure_flex
    flex_login
    put resource_url << '/1.xml', update_failure_parameters, flex_header
    assert_response 200 # OK
    assert_select 'errors' do
      assert_select 'error'
    end
    assert_change_failed
  end

  # Test a failed (not found) put /resources/id request.
  def test_update_not_found
    put resource_url << '/999', update_success_parameters, authorization_header
    assert_response 404 # Not found
    assert_change_failed
  end

  # Test a failed (not found) put /resources/id request from Flex.
  def test_update_not_found_flex
    flex_login
    put resource_url << '/999.xml', update_success_parameters, flex_header
    assert_response 404 # Not found
    assert_change_failed
  end
  
  # Test the delete /resources/id request without credentials.
  def test_destroy_unauthorized
    delete resource_url << '/2', {}, accept_header
    assert_response 401 # Unauthorized
    assert_delete_failed
  end
  
  # Test the delete /resources/id request without credentials from Flex.
  def test_destroy_unauthorized_flex
    delete resource_url << '/2.xml', {}, flex_header
    assert_response 401 # Unauthorized
    assert_delete_failed
  end

  # Test a successful delete /resources/id request .
  def test_destroy_success
    delete resource_url << '/2', {}, authorization_header
    assert_response 200 # Success
    assert_delete_succeeded
  end

  # Test a successful delete /resources/id request from Flex.
  def test_destroy_success_flex
    flex_login
    delete resource_url << '/2.xml', {}, flex_header
    assert_response 200 # Success
    assert_delete_succeeded
  end

  # Test a failed delete /resources/id request.
  def test_destroy_failure
    delete resource_url << '/999', {}, authorization_header
    assert_response 404 # Does not exist
  end

  # Test a failed delete /resources/id request from Flex.
  def test_destroy_failure_flex
    flex_login
    delete resource_url << '/999.xml', {}, flex_header
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
    self.class.to_s.chomp('XmlTest')
  end
end