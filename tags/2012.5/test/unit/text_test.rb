require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  include Utilities::Text

  # Test incrementing a string with a numeric (0) at the end.
  def test_increment_numeric_0
    assert_equal 'Iteration 1', increment_name('Iteration 0')
  end
  
  # Test incrementing a string with a numeric (1) at the end.
  def test_increment_numeric_1
    assert_equal 'Iteration 2', increment_name('Iteration 1')
  end
  
  # Test incrementing a string with a nonnumeric at the end.
  def test_increment_nonnumeric
    assert_nil increment_name('Iteration')
    assert_equal 'foo', increment_name('Iteration', 'foo')
  end
end