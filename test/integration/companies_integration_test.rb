require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../companies_test_helper"
require "#{File.dirname(__FILE__)}/resource_helper"

class CompaniesIntegrationTest < ActionDispatch::IntegrationTest
  include ResourceHelper
  include CompaniesTestHelper

  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :individuals_projects
  fixtures :companies
  fixtures :teams
end