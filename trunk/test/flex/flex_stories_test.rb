require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'

class FlexStoriesTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :teams
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :criteria
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :story_values
  fixtures :tasks
  fixtures :audits

  def setup
  end 
  
  def teardown
  end

  # Populate database for FlexMonkey tests.
  def test_setup
  end 
end