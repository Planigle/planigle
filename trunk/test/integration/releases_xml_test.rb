require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../releases_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class ReleasesXmlTest < ActionController::IntegrationTest
  include ResourceHelper
  include ReleasesTestHelper

  fixtures :individuals
  fixtures :releases
  fixtures :projects
  fixtures :stories

  # Re-raise errors caught by the controller.
  class ReleasesController; def rescue_action(e) raise e end; end
end