require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../projects_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class ProjectsXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include ProjectsTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects

  # Re-raise errors caught by the controller.
  class ProjectsController; def rescue_action(e) raise e end; end
end