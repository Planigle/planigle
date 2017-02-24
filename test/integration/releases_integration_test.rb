require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../releases_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class ReleasesIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include ReleasesTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :releases
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories

  # Re-raise errors caught by the controller.
  class ReleasesController; def rescue_action(e) raise e end; end
end