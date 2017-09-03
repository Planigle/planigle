module CommentsTestHelper
  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:message => 'foo'}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:message => ''}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:record => {:message => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {:record => {:message => ''}}
  end
  
  # Answer the context for this resource (if contained within scope of others).
  def context
    {:story_id => 1}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Comment.count
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Comment.where(message: 'foo').first
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Comment.where(message: 'foo').first
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Comment.where(message: '').first
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Comment.where(message: 'foo').first
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Comment.where(message: 'test2_comment').first
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Comment.where(message: 'test2_comment').first
  end
  
  def base_URL
    '/planigle/api/stories/1/comments'
  end
end