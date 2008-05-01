require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  fixtures :iterations
  fixtures :projects
  fixtures :stories

  # Test that an iteration can be created.
  def test_create_iteration
    assert_difference 'Iteration.count' do
      iteration = create_iteration
      assert !iteration.new_record?, "#{iteration.errors.full_messages.to_sentence}"
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

  # Test the validation of length.
  def test_length
    # Test that we can leave out the length.
    assert_difference get_count do
      obj = Iteration.create({ :name => 'foo', :start => Date.today, :project_id => 1 })
      assert !obj.new_record?, "#{obj.errors.full_messages.to_sentence}"
    end

    assert_failure(:length, nil)
    assert_failure(:length, -1)
    assert_failure(:length, 0)
    assert_success(:length, 2)
    assert_failure(:length, 'foo')
  end

  # Test new based on previous where the name is non-numeric.
  def test_new_based_on_previous_non_numeric_name
    previous = create_iteration({:name => 'foo', :start => Date.today + 14, :length => 2, :project_id => 1})
    iteration = Iteration.new( :project_id => 1 )
    assert_nil iteration.name
    assert_equal previous.start + 14, iteration.start
    assert_equal previous.length, iteration.length
  end
    
  # Test new based on previous where the name is non-numeric.
  def test_new_based_on_previous_numeric_name
    previous = create_iteration({:name => 'iteration 0', :start => Date.today + 14, :length => 3, :project_id => 1})
    iteration = Iteration.new( :project_id => 1 )
    assert_equal 'iteration 1', iteration.name
    assert_equal previous.start + 21, iteration.start
    assert_equal previous.length, iteration.length
  end
  
  # Test deleting an iteration
  def test_delete_iteration
    assert_equal stories(:first).iteration, iterations(:first)
    iterations(:first).destroy
    stories(:first).reload
    assert_nil stories(:first).iteration
  end
  
  # Test updating the project
  def test_update_project
    assert_equal stories(:first).iteration, iterations(:first)
    iterations(:first).project_id = 2
    stories(:first).reload
    assert_equal 2, stories(:first).project_id
  end

private

  # Create an iteration with valid values.  Options will override default values (should be :attribute => value).
  def create_iteration(options = {})
    Iteration.create({ :name => 'foo', :start => Date.today, :length => 2, :project_id => 1 }.merge(options))
  end
end
