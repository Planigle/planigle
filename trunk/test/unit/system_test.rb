require File.dirname(__FILE__) + '/../test_helper'

class SystemTest < ActiveSupport::TestCase
  fixtures :systems
  fixtures :releases
  fixtures :release_totals
  fixtures :iterations
  fixtures :iteration_totals
  fixtures :stories

  # Test the license agreement.
  def test_license_agreement
    system = System.find(:first)
    system.license_agreement = "test"
    system.save(false)
    assert_equal "test", system.license_agreement
  end
  
  # Test summarizing report data.
  def test_summarize
    release1 = Release.create(:project_id => 1, :name => 'start', :start => Date.today, :finish => Date.today + 13)
    iteration1 = Iteration.create(:project_id => 1, :name => 'start', :start => Date.today, :length => 2)
    Story.create(:project_id => 1, :release_id => release1.id, :iteration_id => iteration1.id, :name => 'a', :effort => 2, :status_code => Story::Done)
    release2 = Release.create(:project_id => 1, :name => 'end', :start => Date.today - 13, :finish => Date.tomorrow)
    iteration2 = Iteration.create(:project_id =>1, :name => 'end', :start => Date.today - 13, :length => 2)
    Story.create(:project_id => 1, :release_id => release2.id, :iteration_id => iteration2.id, :name => 'a', :effort => 3, :status_code => Story::Done)
    System.summarize
    assert_equal 2, IterationTotal.find(:all, :conditions => {:iteration_id => iteration1.id, :team_id => nil})[0].done
    assert_equal 3, IterationTotal.find(:all, :conditions => {:iteration_id => iteration2.id, :team_id => nil})[0].done
    assert_equal 2, ReleaseTotal.find(:all, :conditions => {:release_id => release1.id, :team_id => nil})[0].done
    assert_equal 3, ReleaseTotal.find(:all, :conditions => {:release_id => release2.id, :team_id => nil})[0].done
  end
end