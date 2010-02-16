require File.dirname(__FILE__) + '/../test_helper'
require 'individual_mailer'

class IndividualMailerTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :individuals_projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
  end

  # Test notification on signup.
  def test_signup_notification
    c = Company.create(:name => 'foo')
    p = Project.create(:company_id => c.id, :name => 'foo')
    i = Individual.create(:first_name => 'foo', :last_name => 'bar', :login => 'quire' << rand.to_s, :email => 'quire' << rand.to_s << '@example.com', :password => 'quired', :password_confirmation => 'quired', :role => 0, :company_id => c.id, :phone_number => '5555555555', :project_ids => [p.id])
    response = IndividualMailer.create_signup_notification(i)
    assert_equal PLANIGLE_ADMIN_EMAIL, response.from[0]
    assert_equal i.email, response.to[0]
    url_reg = /.*#{IndividualMailer.site}\/activate\/#{i.activation_code}.*/
    assert_match url_reg, response.body
    assert_match /.*enabled for the Premium Edition.*/, response.body
  end
end
