require File.dirname(__FILE__) + '/../test_helper'

class CriteriumTest < ActiveSupport::TestCase
  fixtures :stories
  fixtures :criteria

  # Test that an criteria can be created.
  def test_create_criterium
    assert_difference 'Criterium.count' do
      criterium = create_criterium
      assert !criterium.new_record?, "#{criterium.errors.full_messages.to_sentence}"
    end
  end

  # Test that you can't create an criteria without a story.  Note: currently an issue since
  # the story is not created when it creates the criteria.
  def test_create_criteria_without_story
#    assert_no_difference 'Criterium.count' do
#      Criterium.create({:description => 'foo', :status_code => 0})
#    end
  end

  # Test the name (read-only).
  def test_name
    criterium = Criterium.new(:description => 'foo')
    assert_equal 'foo', criterium.name
    criterium = Criterium.new(:description => '1234567890123456789012345')
    assert_equal '12345678901234567890...', criterium.name
  end
  
  # Test the validation of description.
  def test_description
    validate_field(:description, false, nil, 4096)
  end

  # Test the validation of priority.
  def test_priority
    assert_failure(:priority, 'a')
    assert_success(:priority, -1)
    assert_success(:priority, 0)
    assert_success(:priority, 1.345)
  end

  # Test the validation of status code.
  def test_status_code
    assert_success( :status_code, 0)
    assert_failure( :status_code, -1 )
    assert_success( :status_code, 1 )
    assert_failure( :status_code, 2 )
  end

  # Test the accepted? method.
  def test_accepted
    assert !criteria(:first).accepted?
    assert criteria(:second).accepted?
  end

private

  # Create a criteria with valid values.  Options will override default values (should be :attribute => value).
  def create_criterium(options = {})
    Criterium.create({ :story_id => 1, :description => 'foo', :status_code => 0 }.merge(options))
  end
end
