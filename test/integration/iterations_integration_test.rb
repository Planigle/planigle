require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../iterations_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class IterationsIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include IterationsTestHelper

  fixtures :statuses
  fixtures :systems
  fixtures :individuals
  fixtures :iterations
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories
end