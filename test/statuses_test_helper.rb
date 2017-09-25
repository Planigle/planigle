module StatusesTestHelper
    # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:name => 'foo', :status_code => 1, :applies_to_stories => true, :applies_to_tasks => true, ordering: 5, :project_id => 1}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:name => '', :status_code => 1, :applies_to_stories => true, :applies_to_tasks => true, ordering: 5, :project_id => 1}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:record => {:name => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {:record => {:name => ''}}
  end
  
  # Answer the context for this resource (if contained within scope of others).
  def context
    {}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Status.where(project_id: 1).count
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Status.where(name: 'foo').first
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Status.where(name: 'foo').first
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Status.where(name: '').first
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Status.where(name: 'foo').first
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Status.where(id: 17).first
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Status.where(id: 17).first
  end
  
  def base_URL
    '/planigle/api/statuses'
  end
end