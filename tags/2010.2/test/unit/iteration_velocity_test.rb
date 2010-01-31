require File.dirname(__FILE__) + '/../test_helper'

class IterationVelocityTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :iterations

  # Test summarization.
  def test_summarize
    num = IterationVelocity.count
    total = IterationVelocity.capture( 4, nil, 2, 3, 4, 5)
    assert_equal num + 1, IterationVelocity.count
    assert_equal 14, total.attempted
    assert_equal 4, total.completed
    IterationVelocity.capture( 4, nil, 5, 6, 7, 8)
    total.reload
    assert_equal num + 1, IterationVelocity.count
    assert_equal 14, total.attempted
    assert_equal 7, total.completed
  end
end