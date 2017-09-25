require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../individuals_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IndividualsIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include IndividualsTestHelper

  fixtures :systems
  fixtures :individuals
  
  class IndividualsController
    # Change so that we're not redirected to SSL.
    def ssl_supported?
      false
    end

    # Re-raise errors caught by the controller.
    def rescue_action(e)
      raise e
    end
  end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    IndividualMailer.site = 'www.testxyz.com'
    admin2 = individuals(:admin2)
    admin2.selected_project_id=1
    admin2.save( :validate=> false )
  end

  # Test that you can't delete yourself.
  def test_destroy_self
    delete resource_url << '/6', params: {}, headers: authorization_header
    assert_response 401 # Unprocessable Entity
    assert Individual.find_by_login('quentin')
  end

  # Test a successful get /resources request.
  def test_index_success
    login_as(individuals(:admin2))
    get resource_url, params: {}, headers: authorization_header
    assert_response :success
    assert_equal 5, json.length
  end
end
