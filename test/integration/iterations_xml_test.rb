require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IterationsXmlTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include IterationsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :iterations
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories

  # Re-raise errors caught by the controller.
  class IterationsController; def rescue_action(e) raise e end; end
end