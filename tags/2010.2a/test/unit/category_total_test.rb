require File.dirname(__FILE__) + '/../test_helper'

class CategoryTotalTest < ActiveSupport::TestCase
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
    story = create_story(:name => 'test', :status_code => 1, :release_id => 1, :iteration_id => iteration.id, :team_id => 1, :individual_id => 2, :is_public => true, :custom_5 => 1, :effort => 3)
    create_story(:name => 'test2', :status_code => 0, :release_id => nil, :iteration_id => iteration.id, :team_id => nil, :individual_id => nil, :is_public => false, :custom_5 => nil, :effort => 2)
    iteration.reload()
    totals = CategoryTotal.summarize_for(iteration)
    verify_totals(totals, 1, 3, {5 => "1", 19 => "1", 9 => "1", 10 => "2", 13 => "1", 14 => "1"})
    verify_totals(totals, nil, 2, {5 => "0", 19 => "null", 9 => "null", 10 => "null", 13 => "0", 14 => "0"})
  end

private

  # Verify that the totals are as expected
  def verify_totals(collect, team_id, effort, mapping)
      mapping.keys.each do |key|
      values = collect.select {|total| total.team_id == team_id && total.story_attribute_id == key && total.category == mapping[key]}
      assert_equal 1, values.length, key
      assert_equal effort, values[0].total
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
