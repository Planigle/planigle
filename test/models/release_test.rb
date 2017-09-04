require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase
  fixtures :teams
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :releases
  fixtures :release_totals
  fixtures :projects
  fixtures :iterations
  fixtures :stories
  fixtures :story_attribute_values

  # Test that a release can be created.
  def test_create_release
    assert_difference 'Release.count' do
      release = create_release
      assert !release.new_record?, "#{release.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, true, 1, 40)
  end

  # Test the validation of start.
  def test_start
    assert_success(:start, Date.today)
    assert_failure(:start, nil)
    assert_failure(:start, '2')
  end

  # Test the validation of finish.
  def test_finish
    assert_success(:finish, Date.today)
    assert_failure(:finish, Date.today - 1) # Must be after start
    assert_failure(:finish, nil)
    assert_failure(:finish, '2')
  end
  
  # Test deleting an release
  def test_delete_release
    total_count = ReleaseTotal.count
    assert_equal stories(:first).release, releases(:first)
    assert_equal story_attribute_values(:fourth).release, releases(:first)
    releases(:first).destroy
    stories(:first).reload
    assert_nil StoryAttributeValue.find_by_id(4)
    assert_nil stories(:first).release
    assert_equal total_count - 2, ReleaseTotal.count
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal 0, Release.get_records(individuals(:quentin).project_id).length
    assert_equal Release.where(project_id: 1).length, Release.get_records(individuals(:aaron).project_id).length
    user = individuals(:user)
    user.selected_project_id = 1
    assert_equal Release.where(project_id: 1).length, Release.get_records(user.project_id).length
    assert_equal Release.where(project_id: 1).length, Release.get_records(individuals(:readonly).project_id).length
  end
  
  # Test finding the current release
  def test_find_current
    assert_nil Release.find_current(individuals(:admin2).project_id)
    release = create_release()
    assert_equal release, Release.find_current(individuals(:admin2).project_id)
  end
  
  # Test summarization.
  def test_summarize
    totals = releases(:first).summarize
    totals.each do |total|
      if total.team == nil
        assert_equal 0, total.in_progress
        assert_equal 1, total.done
      end
      if total.team == teams(:first)
        assert_equal 1, total.in_progress
        assert_equal 0, total.done
      end
    end
  end

private

  # Create an release with valid values.  Options will override default values (should be :attribute => value).
  def create_release(options = {})
    Release.create({ :name => 'foo', :start => Date.today, :finish => Date.today + 14, :project_id => 1 }.merge(options))
  end
end
