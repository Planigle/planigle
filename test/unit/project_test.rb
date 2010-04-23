require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :teams
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :story_attributes
  fixtures :stories
  fixtures :surveys

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    config_option_set(:who_to_notify, 'ksksk@ksdkdaiu.com')
  end

  # Test that an project can be created.
  def test_create_project
    assert_difference 'Project.count' do
      project = create_project
      assert !project.new_record?, "#{project.errors.full_messages.to_sentence}"
      assert_equal 16, project.story_attributes.length
    end
  end

  def test_company_id
    assert_failure(:company_id, nil)
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test the validation of track actuals.
  def test_track_actuals
    assert_success(:track_actuals, true)
    assert_success(:track_actuals, false)
  end

  # Test the validation of survey_mode.
  def test_survey_mode
    project = create_project
    assert_equal 0, project.survey_mode # Defaults to Private (0)
    assert_success( :survey_mode, 0)
    assert_failure( :survey_mode, -1 )
    assert_failure( :survey_mode, 3 )
  end

  # Test the validation of premium_expiry.
  def test_premium_expiry
    assert_success(:premium_expiry, Date.today)
    assert_equal Date.today + 30, create_project().premium_expiry
  end

  # Test the validation of premium_limit.
  def test_premium_limit
    assert_failure( :premium_limit, nil )
    assert_failure( :premium_limit, 0 )
    assert_failure( :premium_limit, 1.5 )
    assert_success( :premium_limit, 1 )
  end

  # Test deleting an project
  def test_delete_project
    assert_equal projects(:first), teams(:first).project
    assert_equal projects(:first), individuals(:aaron).projects[0]
    assert_equal projects(:first), individuals(:admin2).projects[0]
    assert_equal projects(:first), releases(:first).project
    assert_equal projects(:first), iterations(:first).project
    assert_equal projects(:first), stories(:first).project
    assert_equal projects(:first), surveys(:first).project
    assert_equal projects(:first), story_attributes(:first).project
    i = individuals(:quentin)
    i.selected_project_id = 1
    i.save(false)
    assert_equal projects(:first), individuals(:quentin).selected_project
    projects(:first).destroy
    assert_nil Team.find_by_id(1)
    assert Individual.find_by_id(6).projects.empty?
    assert_nil Release.find_by_id(1)
    assert_nil Iteration.find_by_id(1)
    assert_nil Story.find_by_id(1)
    assert_nil Survey.find_by_id(1)
    assert_nil StoryAttribute.find_by_id(1)
    assert Individual.find_by_id(2).projects.empty?
    assert_nil Individual.find_by_id(1).selected_project
    assert Individual.find_by_id(6).projects.empty?
  end

  # Test the xml created for surveys.
  def test_create_survey
    survey = projects(:first).create_survey
    assert_tag( survey, :stories)
    assert_tag( survey, :story)
    assert_tag( survey, :id)
    assert_tag( survey, :name)
    assert_tag( survey, :description)
    assert_tag( survey, :priority)
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal Project.count, Project.get_records(individuals(:quentin)).length
    assert_equal 2, Project.get_records(individuals(:aaron)).length
    assert_equal 2, Project.get_records(individuals(:user)).length
    assert_equal 2, Project.get_records(individuals(:readonly)).length
    assert_equal 1, Project.get_records(individuals(:project_admin2)).length
    assert_equal 1, Project.get_records(individuals(:user2)).length
    assert_equal 1, Project.get_records(individuals(:ro2)).length
  end
  
  # Validate is_premium.
  def test_is_premium
    assert projects(:first).is_premium
    assert !projects(:second).is_premium
  end
  
  # Validate that notifications get sent
  def test_send_notifications
    config_option_set(:notify_of_inactivity_after, 3)
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today - 2)
    project.individuals << create_individual(:last_login => today - 4)
    notifications = ActionMailer::Base.deliveries.length
    Project.send_notifications
    assert_equal notifications+2, ActionMailer::Base.deliveries.length
  end
  
  # Validate update_notifications
  def test_update_notifications_no_change
    project = create_project
    now = Time.now
    project.last_notified_of_expiration = now
    project.save(false)
    assert_equal now, project.last_notified_of_expiration
  end
  
  # Validate update_notifications
  def test_update_notifications_change
    project = create_project
    today = Date.today
    project.last_notified_of_expiration = today
    project.save(false)
    assert_equal today, project.last_notified_of_expiration
    project.premium_expiry = today
    project.save(false)
    assert_equal nil, project.last_notified_of_expiration
  end
  
  # Validate test_notify_of_inactivity
  def test_notify_of_inactivity_active
    config_option_set(:notify_of_inactivity_after, 3)
    project = create_project
    notifications = ActionMailer::Base.deliveries.length
    project.notify_of_inactivity
    assert_equal notifications, ActionMailer::Base.deliveries.length
  end
  
  # Validate test_notify_of_inactivity
  def test_notify_of_inactivity_inactive
    config_option_set(:notify_of_inactivity_after, 3)
    project = create_project
    now = Time.now
    project.individuals << create_individual(:last_login => now - 3*24*60*60 - 60)
    notifications = ActionMailer::Base.deliveries.length
    project.notify_of_inactivity
    assert_equal notifications + 1, ActionMailer::Base.deliveries.length
  end

  # Validate last login
  def test_last_login
    project = create_project
    now = Time.now
    project.individuals << create_individual(:last_login => now - 3)
    project.individuals << create_individual(:last_login => now - 5)
    project.individuals << create_individual
    assert_equal now - 3, project.last_login
  end

  # Validate admin_email_addresses
  def test_admin_email_addresses
    project = create_project
    project.individuals << create_individual(:email => 'foo@example.com', :role => Individual::Admin)
    project.individuals << create_individual(:email => 'bar@example.com', :role => Individual::ProjectAdmin)
    project.individuals << create_individual(:email => 'fred@example.com', :role => Individual::ProjectUser)
    project.individuals << create_individual(:email => 'sam@example.com', :role => Individual::ReadOnlyUser)
    emails = project.admin_email_addresses
    assert_equal 1, emails.length
    assert_equal 'bar@example.com', emails[0]
  end
  
  # Validate is_inactive
  def test_is_inactive_no_setting
    config_option_set(:notify_of_inactivity, nil)
    project = Project.new
    assert !project.is_inactive
  end
  
  # Validate is_inactive
  def test_is_inactive_recent_users
    config_option_set(:notify_of_inactivity_after, 3)
    now = Time.now
    project = Project.new
    project.individuals << create_individual(:last_login => now - 3*60*60*24 + 60)
    assert !project.is_inactive
  end
  
  # Validate is_inactive
  def test_is_inactive_no_recent_users
    config_option_set(:notify_of_inactivity_after, 3)
    now = Time.now
    project = Project.new
    project.individuals << create_individual(:last_login => now - 3*60*60*24 - 60)
    assert project.is_inactive
  end
  
  # Validate is_inactive
  def test_is_inactive_no_recent_users_notified
    config_option_set(:notify_of_inactivity_after, 3)
    now = Time.now
    project = Project.new(:last_notified_of_inactivity => now)
    project.individuals << create_individual(:last_login => now - 3*60*60*24 - 60)
    assert !project.is_inactive
  end
  
  # Validate is_inactive
  def test_is_inactive_no_users_in_range
    config_option_set(:notify_of_inactivity_after, 3)
    config_option_set(:notify_of_inactivity_before, 5)
    now = Time.now
    project = Project.new
    project.individuals << create_individual(:last_login => now - 5*60*60*24 - 60)
    assert !project.is_inactive
  end
  
  # Validate is_inactive
  def test_is_inactive_users_in_range
    config_option_set(:notify_of_inactivity_after, 3)
    config_option_set(:notify_of_inactivity_before, 5)
    now = Time.now
    project = Project.new
    project.individuals << create_individual(:last_login => now - 5*60*60*24 + 60)
    assert project.is_inactive
  end
  
  # Validate test_notify_of_expiration
  def test_notify_of_expiration_not_expiring
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today + 4)
    notifications = ActionMailer::Base.deliveries.length
    project.notify_of_expiration
    assert_equal notifications, ActionMailer::Base.deliveries.length
  end
  
  # Validate test_notify_of_expiration
  def test_notify_of_expiration_expiring
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today + 3)
    notifications = ActionMailer::Base.deliveries.length
    project.notify_of_expiration
    assert_equal notifications+1, ActionMailer::Base.deliveries.length
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_not_expiring
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today + 4)
    assert !project.is_about_to_expire
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_expiring
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today + 3)
    assert project.is_about_to_expire
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_expiring_notified
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today + 3)
    project.last_notified_of_expiration = today
    assert !project.is_about_to_expire
  end
  
  # Validate is_about_to_expire
  def test_is_about_to_expire_expired
    config_option_set(:notify_when_expiring_in, 3)
    today = Date.today
    project = create_project(:premium_expiry => today - 1)
    assert !project.is_about_to_expire
  end
  
private

  # Create an project with valid values.  Options will override default values (should be :attribute => value).
  def create_project(options = {})
    Project.create({ :company_id => 1, :name => 'foo' }.merge(options))
  end

  # Create an individual with valid values.  Options will override default values (should be :attribute => value).
  def create_individual(options = {})
    Individual.create({ :first_name => 'foo', :last_name => 'bar', :login => 'quire' << rand.to_s, :email => 'quire' << rand.to_s << '@example.com', :password => 'quired', :password_confirmation => 'quired', :role => 0, :company_id => 1, :project_ids => "1", :phone_number => '5555555555' }.merge(options))
  end
end
