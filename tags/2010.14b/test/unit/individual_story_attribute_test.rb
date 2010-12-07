require File.dirname(__FILE__) + '/../test_helper'

class IndividualStoryAttributeTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :story_attributes
  fixtures :individual_story_attributes

  # Test that an individual story attribute can be created.
  def test_create_individual_story_attribute
    assert_difference 'IndividualStoryAttribute.count' do
      val = create_individualstoryattribute
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
      assert_equal 10, val.ordering.to_i
      assert_equal false, val.show
      assert_equal 135, val.width.to_i
    end

    assert_difference 'IndividualStoryAttribute.count' do
      val = create_individualstoryattribute(:story_attribute_id => 3)
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
      assert_equal 20, val.ordering.to_i
      assert_equal false, val.show
      assert_equal 65, val.width.to_i
    end
  end

  # Test the validation of ordering.
  def test_ordering
    assert_failure(:ordering, -1)
    assert_success(:ordering, 0)
    assert_success(:ordering, 1.5)
  end

  # Test the validation of show.
  def test_show
    assert_success(:show, true)
    assert_success(:show, false)
  end

  # Test the validation of width.
  def test_width
    assert_failure(:width, -1)
    assert_success(:width, 0)
    assert_success(:width, 1)
  end

private

  # Create an individual story attribute with valid values.  Options will override default values (should be :attribute => value).
  def create_individualstoryattribute(options = {})
    IndividualStoryAttribute.create({ :individual_id => 1, :story_attribute_id => 1}.merge(options))
  end
end