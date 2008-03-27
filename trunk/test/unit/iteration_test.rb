require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  fixtures :iterations

  # Test that an iteration can be created.
  def test_should_create_iteration
    assert_difference 'Iteration.count' do
      iteration = create_iteration
      assert !iteration.new_record?, "#{iteration.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of start.
  def test_start
    assert_success(:start, Date.today)
    assert_failure(:start, nil)
    assert_failure(:start, '2')
  end

  # Test the validation of length.
  def test_length
    # Test that we can leave out the length.
    assert_difference get_count do
      obj = Iteration.create({ :name => 'foo', :start => Date.today })
      assert !obj.new_record?, "#{obj.errors.full_messages.to_sentence}"
    end

    assert_success(:length, 2)
    assert_failure(:length, 'foo')
  end

  # Test new based on previous where the name is non-numeric.
  def test_new_based_on_previous_non_numeric_name
    previous = create_iteration({:name => 'foo', :start => Date.today + 14, :length => 2})
    iteration = Iteration.new_based_on_previous
    assert_nil iteration.name
    assert_equal previous.start + 14, iteration.start
    assert_equal previous.length, iteration.length
  end
    
  # Test new based on previous where the name is non-numeric.
  def test_new_based_on_previous_numeric_name
    previous = create_iteration({:name => 'iteration 1', :start => Date.today + 14, :length => 3})
    iteration = Iteration.new_based_on_previous
    assert_equal 'iteration 2', iteration.name
    assert_equal previous.start + 21, iteration.start
    assert_equal previous.length, iteration.length
  end

private

  # Create an iteration with valid values.  Options will override default values (should be :attribute => value).
  def create_iteration(options = {})
    Iteration.create({ :name => 'foo', :start => Date.today, :length => 2 }.merge(options))
  end
end
