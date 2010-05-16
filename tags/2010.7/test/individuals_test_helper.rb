module IndividualsTestHelper
  # Return the parameters to use for a successful create.
  def create_success_parameters
    {:record => {:login => 'foo', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :company_id => 1, :project_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}}
  end

  # Return the parameters to use for a failed create.
  def create_failure_parameters
    {:record => {:login => '', :email => 'foo@sample.com', :last_name => 'bar', :role => 1, :company_id => 1, :project_id => 1,
      :first_name => 'foo', :password => 'testit', :password_confirmation => 'testit'}}
  end

  # Return the parameters to use for a successful update.
  def update_success_parameters
    {:record => {:login => 'foo'}}
  end

  # Return the parameters to use for a failed update.
  def update_failure_parameters
    {:record => {:login => ''}}
  end
  
  # Answer the context for this resource (if contained within scope of others).
  def context
    {}
  end
  
  # Answer the number of resources that exist.
  def resource_count
    Individual.count
  end

  # Verify that the object was created.
  def assert_create_succeeded
    assert Individual.find_by_login('foo')
    assert_equal ActionMailer::Base.deliveries.length, 1
    assert_no_match /.*enabled for the Premium Edition.*/, ActionMailer::Base.deliveries[0].body
  end

  # Verify that the object was updated.
  def assert_update_succeeded
    assert Individual.find_by_login('foo')
  end

  # Verify that the object was not created / updated.
  def assert_change_failed
    assert_nil Individual.find_by_login('')
    assert_equal ActionMailer::Base.deliveries.length, 0
  end

  # Verify that the object was not created / updated with valid changes.
  def assert_valid_change_failed
    assert_nil Individual.find_by_login('foo')
    assert_equal ActionMailer::Base.deliveries.length, 0
  end

  # Verify that the object was deleted.
  def assert_delete_succeeded
    assert_nil Individual.find_by_login('aaron')
  end

  # Verify that the object was not deleted.
  def assert_delete_failed
    assert Individual.find_by_login('aaron')
  end
end