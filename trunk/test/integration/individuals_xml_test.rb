require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../individuals_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IndividualsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include IndividualsTestHelper

  fixtures :individuals

  # Re-raise errors caught by the controller.
  class IndividualsController; def rescue_action(e) raise e end; end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
end
