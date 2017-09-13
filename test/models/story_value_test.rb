require File.dirname(__FILE__) + '/../test_helper'

class StoryValueTest < ActiveSupport::TestCase
  fixtures :statuses
  fixtures :projects
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_values

  # Test that a story value can be created.
  def test_create_story_value
    assert_difference 'StoryValue.count' do
      val = create_storyvalue
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of value.
  def test_value
    validate_field(:value, false, 1, 4096)
  end

private

  # Create a story value with valid values.  Options will override default values (should be :attribute => value).
  def create_storyvalue(options = {})
    StoryValue.create({ :story_id => 3, :story_attribute_id => 1, :value => 'test'}.merge(options))
  end
end
