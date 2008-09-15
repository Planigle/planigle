require File.dirname(__FILE__) + '/../test_helper'

class IterationTotalTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :iterations
  fixtures :iteration_totals

  # Test summarization.
  def test_summarize
    num = IterationTotal.count
    total = IterationTotal.capture( 1, 2, 3, 4)
    assert_equal num + 1, IterationTotal.count
    assert_equal 2, total.created
    assert_equal 3, total.in_progress
    assert_equal 4, total.done
    IterationTotal.capture( 1, 5, 6, 7)
    total.reload
    assert_equal num + 1, IterationTotal.count
    assert_equal 5, total.created
    assert_equal 6, total.in_progress
    assert_equal 7, total.done
  end
end