require "#{File.dirname(__FILE__)}/../test_helper"

class SessionsIntegrationTest < ActionDispatch::IntegrationTest
  fixtures :systems
  fixtures :individuals
end