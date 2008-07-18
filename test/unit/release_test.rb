require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :releases
  fixtures :projects
  fixtures :iterations
  fixtures :stories

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
    assert_equal stories(:first).release, releases(:first)
    releases(:first).destroy
    stories(:first).reload
    assert_nil stories(:first).release
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal Release.count, Release.get_records(individuals(:quentin)).length
    assert_equal Release.find_all_by_project_id(1).length, Release.get_records(individuals(:aaron)).length
    assert_equal Release.find_all_by_project_id(1).length, Release.get_records(individuals(:user)).length
    assert_equal Release.find_all_by_project_id(1).length, Release.get_records(individuals(:readonly)).length
  end

private

  # Create an release with valid values.  Options will override default values (should be :attribute => value).
  def create_release(options = {})
    Release.create({ :name => 'foo', :start => Date.today, :finish => Date.today + 14, :project_id => 1 }.merge(options))
  end
end
