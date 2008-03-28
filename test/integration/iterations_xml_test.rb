require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IterationsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include IterationsTestHelper

  fixtures :individuals
  fixtures :iterations

  # Re-raise errors caught by the controller.
  class IterationsController; def rescue_action(e) raise e end; end
end