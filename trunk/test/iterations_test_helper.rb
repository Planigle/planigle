module IterationsTestHelper
    # Return the parameters to use for a successful create.
  def create_success_parameters
    {:iteration => {:name => 'foo', :start => Date.today}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:iteration => {:name => '', :start => Date.today}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:iteration => {:name => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {:iteration => {:name => ''}}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Iteration.count
  end

  # Answer a symbol which represents the resource.
  def resource_symbol
    :iteration
  end

  # Answer a string used to display this resource as a partial.
  def partial_resource
    '_iterations'
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Iteration.find_by_name('foo')
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Iteration.find_by_name('foo')
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Iteration.find_by_name('')
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Iteration.find_by_name('foo')
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Iteration.find_by_name('second')
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Iteration.find_by_name('second')
  end
end