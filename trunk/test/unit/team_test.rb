require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :companies
  fixtures :teams
  fixtures :individuals
  fixtures :iteration_velocities
  fixtures :iteration_totals
  fixtures :release_totals
  fixtures :stories

  # Test that an test can be created.
  def test_create_team
    assert_difference 'Team.count' do
      team = create_team
      assert !team.new_record?, "#{team.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test deleting an team
  def test_delete_team
    release_total_count = ReleaseTotal.count
    iteration_total_count = IterationTotal.count
    velocity_count = IterationVelocity.count
    assert_equal individuals(:aaron).team, teams(:first)
    assert_equal stories(:first).team, teams(:first)
    teams(:first).destroy
    assert_nil Individual.find_by_id(2).team_id
    assert_nil Story.find_by_id(1).team_id
    assert_equal release_total_count - 1, ReleaseTotal.count
    assert_equal iteration_total_count - 1, IterationTotal.count
    assert_equal velocity_count - 1, IterationVelocity.count
  end

private

  # Create an team with valid values.  Options will override default values (should be :attribute => value).
  def create_team(options = {})
    Team.create({ :name => 'foo' }.merge(options))
  end
end
