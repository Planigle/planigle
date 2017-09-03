module SystemsTestHelper
  # Return the parameters to use for a successful create.
  def create_failure_parameters
    {:record => {:license_agreement => 'foo'}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:record => {:license_agreement => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {}
  end
  
  # Answer the context for this resource (if contained within scope of others).
  def context
    {}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    1
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert_equal 'foo', System.first.reload.license_agreement
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert 'foo', System.first.reload.license_agreement != 'foo'
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert 'foo', System.first.reload.license_agreement != 'foo'
  end
  
  def base_URL
    '/planigle/api/system'
  end
end