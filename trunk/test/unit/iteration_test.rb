require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :iteration_totals
  fixtures :iterations
  fixtures :projects
  fixtures :stories
  fixtures :tasks

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
    assert_failure(:length, nil)
    assert_failure(:length, -1)
    assert_failure(:length, 0)
    assert_success(:length, 2)
    assert_failure(:length, 'foo')
  end
  
  # Test deleting an iteration
  def test_delete_iteration
    assert 4, IterationTotal.count
    assert_equal stories(:first).iteration, iterations(:first)
    iterations(:first).destroy
    stories(:first).reload
    assert_nil stories(:first).iteration
    assert 1, IterationTotal.count
  end
  
  # Test updating the project
  def test_update_project
    assert_equal stories(:first).iteration, iterations(:first)
    iterations(:first).project_id = 2
    stories(:first).reload
    assert_equal 2, stories(:first).project_id
  end

  # Test finding iterations for a specific user.
  def test_find
    assert_equal Iteration.count, Iteration.get_records(individuals(:quentin)).length
    assert_equal Iteration.find_all_by_project_id(1).length, Iteration.get_records(individuals(:aaron)).length
    assert_equal Iteration.find_all_by_project_id(1).length, Iteration.get_records(individuals(:user)).length
    assert_equal Iteration.find_all_by_project_id(1).length, Iteration.get_records(individuals(:readonly)).length
  end
  
  # Test summarization.
  def test_summarize
    total = iterations(:first).summarize
    assert 3, total.in_progress
    assert 3, total.done
  end

private

  # Create an iteration with valid values.  Options will override default values (should be :attribute => value).
  def create_iteration(options = {})
    Iteration.create({ :name => 'foo', :start => Date.today, :length => 2, :project_id => 1 }.merge(options))
  end
end
