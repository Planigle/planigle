require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < ActiveSupport::TestCase
  fixtures :companies
  fixtures :projects
  fixtures :teams
  fixtures :individuals
  fixtures :releases
  fixtures :iterations
  fixtures :story_attributes
  fixtures :stories
  fixtures :surveys

  # Test that an project can be created.
  def test_create_project
    assert_difference 'Company.count' do
      company = create_company
      assert !company.new_record?, "#{company.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test deleting a company
  def test_delete_company
    assert_equal projects(:first).company, companies(:first)
    assert_equal teams(:first).project, projects(:first)
    assert_equal individuals(:aaron).company, companies(:first)
    assert_equal individuals(:admin2).company, companies(:first)
    assert_equal releases(:first).project, projects(:first)
    assert_equal iterations(:first).project, projects(:first)
    assert_equal stories(:first).project, projects(:first)
    assert_equal surveys(:first).project, projects(:first)
    assert_equal story_attributes(:first).project, projects(:first)
    companies(:first).destroy
    assert_nil Project.find_by_id(1)
    assert_nil Team.find_by_id(1)
    assert_nil Individual.find_by_id(6).company
    assert_nil Release.find_by_id(1)
    assert_nil Iteration.find_by_id(1)
    assert_nil Story.find_by_id(1)
    assert_nil Survey.find_by_id(1)
    assert_nil StoryAttribute.find_by_id(1)
    assert_nil Individual.find_by_id(2) # non-admin deleted
    assert Individual.find_by_id(6) # admin set to nil
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal 1, Company.get_records(individuals(:quentin)).length
    assert_equal 1, Company.get_records(individuals(:aaron)).length
    assert_equal 1, Company.get_records(individuals(:user)).length
    assert_equal 1, Company.get_records(individuals(:readonly)).length
  end
  
  # Test the validation of premium_expiry.
  def test_premium_expiry
    assert_success(:premium_expiry, Date.today)
    assert_equal Date.today + 30, create_company().premium_expiry
  end

  # Test the validation of premium_limit.
  def test_premium_limit
    assert_failure( :premium_limit, nil )
    assert_failure( :premium_limit, 0 )
    assert_failure( :premium_limit, 1.5 )
    assert_success( :premium_limit, 1 )
  end

  # Validate is_premium.
  def test_is_premium
    assert companies(:first).is_premium
    assert !companies(:second).is_premium
  end

  # Validate test_notify_of_expiration
  def test_notify_of_expiration_not_expiring
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today + 4)
    notifications = ActionMailer::Base.deliveries.length
    company.notify_of_expiration
    assert_equal notifications, ActionMailer::Base.deliveries.length
  end
  
  # Validate test_notify_of_expiration
  def test_notify_of_expiration_expiring
    Rails.configuration.who_to_notify = "test@example.com"
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today + 3)
    notifications = ActionMailer::Base.deliveries.length
    company.notify_of_expiration
    assert_equal notifications+1, ActionMailer::Base.deliveries.length
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_not_expiring
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today + 4)
    assert !company.is_about_to_expire
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_expiring
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today + 3)
    assert company.is_about_to_expire
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_expiring_notified
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today + 3)
    company.last_notified_of_expiration = today
    assert !company.is_about_to_expire
  end
    
  # Validate is_about_to_expire
  def test_is_about_to_expire_expired
    Rails.configuration.notify_when_expiring_in = 3
    today = Date.today
    company = create_company(:premium_expiry => today - 1)
    assert !company.is_about_to_expire
  end
  
  # Validate update_notifications
  def test_update_notifications_no_change
    company = create_company
    now = Time.now
    company.last_notified_of_expiration = now
    company.save( :validate=> false )
    assert_equal now.utc.to_i, company.last_notified_of_expiration.time.to_i
  end
  
  # Validate update_notifications
  def test_update_notifications_change
    company = create_company
    today = Date.today
    company.last_notified_of_expiration = today
    company.save( :validate=> false )
    assert_equal today, company.last_notified_of_expiration
    company.premium_expiry = today
    company.save( :validate=> false )
    assert_nil company.last_notified_of_expiration
  end

private

  # Create a company with valid values.  Options will override default values (should be :attribute => value).
  def create_company(options = {})
    Company.create({ :name => 'foo' }.merge(options))
  end
end
