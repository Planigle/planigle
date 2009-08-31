require File.dirname(__FILE__) + '/../test_helper'

class IndividualTest < ActiveSupport::TestCase
  fixtures :companies
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :teams
  fixtures :stories

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
  end

  # Test that an individual can be created.
  def test_create_individual
    assert_difference 'Individual.count' do
      individual = create_individual
      assert !individual.new_record?, "#{individual.errors.full_messages.to_sentence}"
    end
  end

  # Test that too many individuals cannot be created.
  def test_create_too_many_individuals
    project = projects(:first)
    project.premium_limit = 4
    project.save(false)
    assert_no_difference 'Individual.count' do
      individual = create_individual
      assert !individual.errors.empty?
    end
    
    assert_success(:enabled, false)
    assert_success(:role, 3)

    individual = individuals(:readonly)
    individual.role = 2
    assert_equal false, individual.valid?

    individual.enabled = false
    assert_equal true, individual.valid?

    individual = individuals(:user2)
    individual.company_id = 1
    individual.attributes = {:project_ids => [1]}
    assert_equal false, individual.valid?
  end

  # Test the validation of login.
  def test_login
    validate_field(:login, false, 2, 40)
    assert_success(:login, 'test')
    assert_failure(:login, 'test') # no duplicates
    assert_failure(:login, 'Test') # no duplicates (case doesn't matter)
  end

  # Test the validation of role.
  def test_role
    assert_failure( :role, -1)
    assert_success( :role, 0)
    assert_success( :role, 3)
    assert_failure( :role, 4)
  end

  # Test the validation of notification_type.
  def test_notification_type
    assert_failure( :notification_type, -1)
    assert_success( :notification_type, 0)
    assert_success( :notification_type, 3)
    assert_failure( :notification_type, 4)
  end

  # Test the validation of email.
  def test_email
    assert_failure(:email, nil)
    assert_failure(:email, 'a@b.c')  # bad if 5 long (plus last bit must be two characters)
    assert_success(:email, 'a@b.ce') # ok if 6 long
    assert_failure(:email, 'a@b.ce') # no duplicates
    assert_failure(:email, 'A@b.ce') # no duplicates (case doesn't matter)
    assert_success(:email, 'a@abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcd.com')  # 100 ok
    assert_failure(:email, 'a@abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijkabcd.com') # 101 not so much
    assert_failure(:email, 'aaaaaa')
    assert_failure(:email, 'aaa@aa')
    assert_failure(:email, 'aa @a.aa')
    assert_failure(:email, 'quentin@example.com') # in use
    assert_failure(:email, 'Quentin@example.com') # case doesn't matter
  end

  # Test the validation of phone number.
  def test_phone_number
    assert_failure(:phone_number, '123456789')
    assert_success(:phone_number, '1234567890')
    assert_success(:phone_number, '1234567890123456(). ')
    assert_failure(:phone_number, '123456789012345678901')
    assert_failure(:phone_number, 'abcdefghij')
    
    assert_success_multiple(:notification_type => Individual::NoNotifications, :phone_number => nil)
    assert_success_multiple(:notification_type => Individual::NoNotifications, :phone_number => '')
    assert_success_multiple(:notification_type => Individual::EmailNotifications, :phone_number => nil)
    assert_success_multiple(:notification_type => Individual::EmailNotifications, :phone_number => '')
    assert_failure_multiple(:notification_type => Individual::SMSNotifications, :phone_number => nil)
    assert_failure_multiple(:notification_type => Individual::SMSNotifications, :phone_number => '')
    assert_failure_multiple(:notification_type => Individual::BothNotifications, :phone_number => nil)
    assert_failure_multiple(:notification_type => Individual::BothNotifications, :phone_number => '')
  end

  # Test the validation of last name.
  def test_last_name
    validate_field(:last_name, false, 1, 40)
  end

  # Test the validation of first name.
  def test_first_name
    validate_field(:first_name, false, 1, 40)
  end

  # Test the validation of enabled.  Anything but nil, 'true', 't' or true will be false.
  def test_enabled
    indiv = create_individual( :enabled => 'test')
    assert !indiv.enabled

    indiv = create_individual( :enabled => 'true')
    assert indiv.enabled

    indiv = create_individual( :enabled => 't')
    assert indiv.enabled

    indiv = create_individual() # enabled is not set
    assert indiv.enabled

    indiv = create_individual( :enabled => false)
    assert !indiv.enabled

    indiv = create_individual( :enabled => true)
    assert indiv.enabled
  end

  # Test setting team_id
  def test_team_id
    indiv = create_individual( :project_ids => [], :team_id => 1 )
    assert indiv.errors.on(:team)

    indiv = create_individual( :project_ids => [2], :team_id => 1 )
    assert indiv.errors.on(:team)

    indiv = create_individual( :project_ids => [1], :team_id => 1 )
    assert_nil indiv.errors.on(:team)
  end
  
  # Test setting project_id
  def test_project_id
    indiv = create_individual( :role => 1, :project_ids => [] )
    assert indiv.errors.on(:project)

    indiv = create_individual( :role => 2, :project_ids => "" )
    assert indiv.errors.on(:project)

    indiv = create_individual( :role => 3, :project_ids => "" )
    assert indiv.errors.on(:project)

    indiv = create_individual( :role => 1, :project_ids => [1] )
    assert_nil indiv.errors.on(:project)

    indiv = create_individual( :role => 2, :project_ids => "1" )
    assert_nil indiv.errors.on(:project)

    indiv = create_individual( :role => 3, :project_ids => "1" )
    assert_nil indiv.errors.on(:project)

    indiv = create_individual( :company_id => nil, :project_ids => "1" )
    assert indiv.errors.on(:project)

    indiv = create_individual( :company_id => 2, :project_ids => "1" )
    assert indiv.errors.on(:project)

    indiv = create_individual( :company_id => 1, :project_ids => "1" )
    assert_nil indiv.errors.on(:project)
    
    indiv = create_individual( :company_id => 1, :project_ids => "1,3" )
    assert_nil indiv.errors.on(:project)
    assert_equal 2, indiv.projects.length
    
    indiv = create_individual( :company_id => 1, :project_ids => "1,2" )
    assert indiv.errors.on(:project)

    indiv = create_individual( :company_id => 1, :project_ids => "1" )
    assert_nil indiv.errors.on(:project)
    assert_equal 1, indiv.projects.length
    indiv.attributes( :project_ids => "1,3" )
    assert_nil indiv.errors.on(:project)
    assert_equal 2, indiv.projects.length
    assert_equal "1", indiv.changed_attributes["project_id"][0]
    assert_equal "1,3", indiv.changed_attributes["project_id"][1]
    indiv.attributes( :project_ids => "3" )
    assert_nil indiv.errors.on(:project)
    assert_equal 1, indiv.projects.length

    indiv = create_individual( :company_id => 1, :project_ids => "1,3" )
    assert_nil indiv.errors.on(:project)
    assert_equal 2, indiv.projects.length
    indiv.attributes( :project_id => 1 )
    assert_nil indiv.errors.on(:project)
    assert_equal 1, indiv.projects.length
  end
  
  # Test setting selected_project_id
  def test_selected_project_id
    assert_success(:selected_project_id, nil)
    assert_success(:selected_project_id, 1)
    assert_success(:selected_project_id, 2) # Try for admin

    obj = create_individual( :role => 1,:selected_project_id => 2)
    assert_equal 1, obj.selected_project_id
    assert obj.errors.empty?
    
    indiv = create_individual(:selected_project_id => nil)
    assert_equal 1, indiv.selected_project_id # should default to first project
    
    indiv = create_individual(:selected_project_id => 1, :project_ids => [1, 3])
    projects(:first).destroy
    assert_equal 3, indiv.reload.selected_project_id
    projects(:third).destroy
    assert_nil indiv.reload.selected_project_id
  end
  
  # Test the method project_id
  def test_project_id
    i = individuals(:quentin)
    assert_equal nil, i.project_id
    i.selected_project_id = 1
    assert_equal 1, i.project_id
    i = individuals(:aaron)
    assert_equal 1, i.project_id
    i.selected_project_id = 3
    assert_equal 3, i.project_id
    i = individuals(:project_admin2)
    assert_equal 2, i.project_id
    i.selected_project_id = 4
    assert_equal 4, i.project_id
  end
  
  # Test setting company_id
  def test_company_id
    indiv = create_individual( :role => 1, :company_id => nil )
    assert indiv.errors.on(:company)

    indiv = create_individual( :role => 2, :company_id => nil )
    assert indiv.errors.on(:company)

    indiv = create_individual( :role => 3, :company_id => nil )
    assert indiv.errors.on(:company)

    indiv = create_individual( :role => 1, :company_id => 1 )
    assert_nil indiv.errors.on(:company)

    indiv = create_individual( :role => 2, :company_id => 1 )
    assert_nil indiv.errors.on(:company)

    indiv = create_individual( :role => 3, :company_id => 1 )
    assert_nil indiv.errors.on(:company)
  end

  # Test the validation of last_login.
  def test_last_login
    assert_success(:last_login, nil)
    assert_success(:last_login, Time.now)
  end

  # Test the validation of agreement_accepted.
  def test_agreement_accepted
    assert_success(:agreement_accepted, nil)
    assert_success(:agreement_accepted, Time.now)
  end

  # Test that the individual's activation code is set on creation.
  def test_initialize_activation_code_upon_creation
    individual = create_individual
    assert_not_nil individual.reload.activation_code
    assert !individual.activated? #verify not activated
    Individual.activate(individual.activation_code).save
    assert individual.reload.activated? #verify now activated
  end

  # Test that the password must be set.
  def test_require_password
    assert_no_difference 'Individual.count' do
      indiv = create_individual(:password => nil)
      assert indiv.errors.on(:password)
    end
  end

  # Test that the password must match confirmation.
  def test_password_confirmation_not_set
    assert_no_difference 'Individual.count' do
      indiv = create_individual(:password_confirmation => nil)
      assert indiv.errors.on(:password_confirmation)
    end
  end

  # Test that the password must match confirmation.
  def test_password_confirmation_no_match
    assert_no_difference 'Individual.count' do
      indiv = create_individual(:password_confirmation => 'different')
      assert indiv.errors.on(:password)
    end
  end

  # Test the password size validation.
  def test_password_size
    assert_no_difference 'Individual.count' do
      too_small = create_string(5)
      indiv = create_individual(:password => too_small, :password_confirmation => too_small)
      assert indiv.errors.on(:password)
    end

    assert_difference 'Individual.count' do
      good_size = create_string(6)
      indiv = create_individual(:password => good_size, :password_confirmation => good_size)
      assert !indiv.new_record?, "#{indiv.errors.full_messages.to_sentence}"
    end

    assert_difference 'Individual.count' do
      good_size = create_string(40)
      indiv = create_individual(:password => good_size, :password_confirmation => good_size)
      assert !indiv.new_record?, "#{indiv.errors.full_messages.to_sentence}"
    end

    assert_no_difference 'Individual.count' do
      too_big = create_string(41)
      indiv = create_individual(:password => too_big, :password_confirmation => too_big)
      assert indiv.errors.on(:password)
    end
  end

  # Test what happens when the user changes their password.
  def test_should_reset_password
    individuals(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal individuals(:quentin), Individual.authenticate('quentin', 'new password')
  end

  # Test to ensure that changing the login doesn't mess up the password.
  def test_should_not_rehash_password
    individuals(:quentin).update_attributes(:login => 'quentin2')
    assert_equal individuals(:quentin), Individual.authenticate('quentin2', 'testit')
  end

  # Test that an individual can be authenticated.
  def test_authenticate_individual
    assert_equal individuals(:quentin), Individual.authenticate('quentin', 'testit')
    assert_equal individuals(:quentin), Individual.authenticate('QuEnTiN', 'testit') # case insensitive
    assert_nil Individual.authenticate('quentin', 'wrong' )
    assert_nil Individual.authenticate('quentin', 'TeStIt' ) # case sensitive password
  end

  # Test that an individual can't be authenticated if not yet authenticated.
  def test_authenticate_not_activated
    assert_nil Individual.authenticate('ted', 'testit')
  end

  # Test that an individual can't be authenticated if not yet authenticated.
  def test_authenticate_not_enabled
    individuals(:quentin).enabled = false
    individuals(:quentin).save(false)
    assert_nil Individual.authenticate('quentin', 'testit')
  end

  # Test the remember cookie.
  def test_set_remember_token
    individuals(:quentin).remember_me
    assert_not_nil individuals(:quentin).remember_token
    assert_not_nil individuals(:quentin).remember_token_expires_at
  end

  # Test forgetting the cookie.
  def test_unset_remember_token
    individuals(:quentin).remember_me
    assert_not_nil individuals(:quentin).remember_token
    individuals(:quentin).forget_me
    assert_nil individuals(:quentin).remember_token
  end

  # Test remembering for default of two weeks from now.
  def test_remember_me_default_two_weeks
    time = 2.week.from_now.utc
    individuals(:quentin).remember_me
    assert_not_nil individuals(:quentin).remember_token
    assert_not_nil individuals(:quentin).remember_token_expires_at
    assert individuals(:quentin).remember_token_expires_at - time < 60 # <60 seconds off from when we say to expire.
  end

  # Test the xml created for stories.
  def test_xml
    individ = individuals(:quentin)
    assert_no_tag( individ, :crypted_password )
    assert_no_tag( individ, :salt )
    assert_no_tag( individ, :remember_token )
    assert_no_tag( individ, :remember_token_expires_at )
    assert_no_tag( individ, :activated_code )
    assert_no_tag( individ, :activated_at )
  end
  
  # Test deleting an individual
  def test_delete_individual
    assert_equal stories(:first).individual, individuals(:aaron)
    individuals(:aaron).destroy
    stories(:first).reload
    assert_nil stories(:first).individual
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal Individual.count, Individual.get_records(individuals(:quentin)).length
    assert_equal Individual.find_all_by_company_id(1, :conditions => "role != 0").length, Individual.get_records(individuals(:aaron)).length
    assert_equal Individual.find_all_by_company_id(1, :conditions => "role != 0").length, Individual.get_records(individuals(:user)).length
    assert_equal Individual.find_all_by_company_id(1, :conditions => "role != 0").length, Individual.get_records(individuals(:readonly)).length
    assert_equal Individual.find(:all, :joins => :projects, :conditions => "projects.id = 2 and role != 0").length, Individual.get_records(individuals(:project_admin2)).length
    assert_equal Individual.find(:all, :joins => :projects, :conditions => "projects.id = 2 and role != 0").length, Individual.get_records(individuals(:user2)).length
    assert_equal Individual.find(:all, :joins => :projects, :conditions => "projects.id = 4 and role != 0").length, Individual.get_records(individuals(:ro2)).length
  end
  
  # Validate is_premium.
  def test_is_premium
    assert individuals(:aaron).is_premium
    assert !individuals(:quentin).is_premium
    assert individuals(:user).is_premium
  end

private

  # Create an individual with valid values.  Options will override default values (should be :attribute => value).
  def create_individual(options = {})
    Individual.create({ :first_name => 'foo', :last_name => 'bar', :login => 'quire' << rand.to_s, :email => 'quire' << rand.to_s << '@example.com', :password => 'quired', :password_confirmation => 'quired', :role => 0, :company_id => 1, :project_ids => "1", :phone_number => '5555555555' }.merge(options))
  end
end