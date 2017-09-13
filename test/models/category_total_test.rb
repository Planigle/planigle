require File.dirname(__FILE__) + '/../test_helper'

class CategoryTotalTest < ActiveSupport::TestCase
  fixtures :statuses
  fixtures :companies
  fixtures :projects
  fixtures :teams
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :stories
  fixtures :story_values
  
  def test_summarize_for
    iteration = create_iteration
    create_story(:name => 'test', :status_code => 1, :release_id => 1, :iteration_id => iteration.id, :team_id => 1, :individual_id => 2, :is_public => true, :custom_5 => 1, :effort => 3)
    create_story(:name => 'test2', :status_code => 0, :release_id => nil, :iteration_id => iteration.id, :team_id => nil, :individual_id => nil, :is_public => false, :custom_5 => nil, :effort => 2)
    iteration.reload()
    verify_totals(CategoryTotal.summarize_for(iteration, 1), 3, {"Test_List"=>"Value 1", "Test_Release"=>"None", "Iteration"=>"foo", "Team"=>"Test_team", "Owner"=>"aaron hank", "Status"=>"In Progress", "Public"=>"True", "Release"=>"first"})
    verify_totals(CategoryTotal.summarize_for(iteration, nil), 2, {"Test_List"=>"None", "Test_Release"=>"None", "Iteration"=>"foo", "Team"=>"No Team", "Owner"=>"No Owner", "Status"=>"Not Started", "Public"=>"False", "Release"=>"No Release"})
  end

private

  # Verify that the totals are as expected
  def verify_totals(hash, effort, mapping)
    mapping.keys.each do |key|
      value = hash[key][0]
      assert_equal mapping[key], value.category
      assert_equal effort, value.total
    end
  end

  # Create an iteration with valid values.  Options will override default values (should be :attribute => value).
  def create_iteration(options = {})
    Iteration.create({ :name => 'foo', :start => Date.today, :finish => Date.today + 14, :project_id => 1 }.merge(options))
  end

  # Create a story with valid values.  Options will override default values (should be :attribute => value).
  def create_story(options = {})
    Story.create({ :name => 'foo', :description => 'bar', :effort => 5.0, :acceptance_criteria => 'must',
      :status_code => 0, :project_id => 1 }.merge(options))
  end
end
