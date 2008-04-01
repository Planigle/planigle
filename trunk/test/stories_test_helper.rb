module StoriesTestHelper
  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:story => {:name => 'foo'}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:story => {:name => ''}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:story => {:name => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {:story => {:name => ''}}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Story.count
  end

  # Answer a symbol which represents the resource.
  def resource_symbol
    :story
  end

  # Answer a string used to display this resource as a partial.
  def partial_resource
    '_stories'
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Story.find_by_name('foo')
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Story.find_by_name('foo')
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Story.find_by_name('')
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Story.find_by_name('foo')
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Story.find_by_name('test2')
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Story.find_by_name('test2')
  end
end