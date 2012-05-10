require File.dirname(__FILE__) + '/../test_helper'

class IterationTotalTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :iterations
  fixtures :iteration_story_totals

  # Test summarization.
  def test_summarize
    num = IterationStoryTotal.count
    total = IterationStoryTotal.capture( 1, nil, 2, 3, 4, 5)
    assert_equal num + 1, IterationStoryTotal.count
    assert_equal 2, total.created
    assert_equal 3, total.in_progress
    assert_equal 4, total.done
    assert_equal 5, total.blocked
    IterationStoryTotal.capture( 1, nil, 5, 6, 7, 8)
    total.reload
    assert_equal num + 1, IterationStoryTotal.count
    assert_equal 5, total.created
    assert_equal 6, total.in_progress
    assert_equal 7, total.done
    assert_equal 8, total.blocked
  end
end