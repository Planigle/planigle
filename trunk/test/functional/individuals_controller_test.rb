require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../individuals_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "individuals_controller"

# Re-raise errors caught by the controller.
class IndividualsController; def rescue_action(e) raise e end; end

class IndividualsControllerTest < Test::Unit::TestCase
  include ControllerResourceHelper
  include IndividualsTestHelper
  
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = IndividualsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test activating a user.
  def test_should_activate_user
    assert_nil Individual.authenticate('aaron', 'testit')
    get :activate, :activation_code => individuals(:aaron).activation_code
    assert_redirected_to '/'
    assert_equal individuals(:aaron), Individual.authenticate('aaron', 'testit')
  end

  # Test activation without a key.
  def test_should_not_activate_user_without_key
    get :activate
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  # Test activation with a blank key.
  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # well played, sir
  end
    
  # Test deleting yourself.
  def test_delete_self
    login_as(individuals(:quentin))
    delete :destroy, :id => 1
    assert_redirected_to :action => :index
    assert Individual.find_by_login('quentin')
  end
end
