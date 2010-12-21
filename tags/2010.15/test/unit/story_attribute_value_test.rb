require File.dirname(__FILE__) + '/../test_helper'

class StoryAttributeValueTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :story_values

  # Test that a story attribute value can be created.
  def test_create_story_attribute_value
    assert_difference 'StoryAttributeValue.count' do
      val = create_storyattributevalue
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of value.
  def test_value
    validate_field(:value, true, nil, 100)
  end

private

  # Create a story attribute value with valid values.  Options will override default values (should be :attribute => value).
  def create_storyattributevalue(options = {})
    StoryAttributeValue.create({ :story_attribute_id => 4, :value => 'alpha'}.merge(options))
  end
end