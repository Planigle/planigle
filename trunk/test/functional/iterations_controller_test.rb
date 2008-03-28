require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/controller_resource_helper"
require "iterations_controller"

# Re-raise errors caught by the controller.
class IterationsController; def rescue_action(e) raise e end; end

class IterationsControllerTest < Test::Unit::TestCase
  include ControllerResourceHelper
  include IterationsTestHelper

  fixtures :individuals
  fixtures :iterations

  def setup
    @controller = IterationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test successfully creating a iteration while returning html for the new list of iterations.
  def test_create_partial
    login_as(individuals(:quentin))
    post :create, :iteration => { :name => 'iteration 1', :start => Date.today } # Must follow an iteration with a number at end of name
    num_iterations = Iteration.count
    xhr :post, :create, {}
    assert_response :success
    assert_template "_iterations"
    assert_equal num_iterations+1, Iteration.count
  end
end