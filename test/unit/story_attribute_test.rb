require File.dirname(__FILE__) + '/../test_helper'

class StoryAttributeTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_values

  # Test that a story attribute can be created.
  def test_create_story_attribute
    assert_difference 'StoryAttribute.count' do
      val = create_storyattribute
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of type.
  def test_type
    validate_field(:value_type, false, nil, nil)
    assert_failure(:value_type, -1)
    assert_success(:value_type, 0)
    assert_success(:value_type, 2)
    assert_failure(:value_type, 3)
  end

private

  # Create a story value with valid values.  Options will override default values (should be :attribute => value).
  def create_storyattribute(options = {})
    StoryAttribute.create({ :project_id => 1, :name => 'alpha', :value_type => 2}.merge(options))
  end
end