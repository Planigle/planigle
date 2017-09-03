module TasksTestHelper
  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:name => 'foo'}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:name => ''}}
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
    {:story_id => 1}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Task.count
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Task.where(name: 'foo').first
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Task.where(name: 'foo').first
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Task.where(name: '').first
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Task.where(name: 'foo').first
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Task.where(name: 'test2_task').first
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Task.where(name: 'test2_task').first
  end
  
  def base_URL
    '/planigle/api/stories/1/tasks'
  end
end