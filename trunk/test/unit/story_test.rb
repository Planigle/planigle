require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  fixtures :stories
  fixtures :tasks

  # Test that a story can be created.
  def test_should_create_story
    assert_difference 'Story.count' do
      story = create_story
      assert !story.new_record?, "#{story.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, nil, 40)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test the validation of acceptance criteria.
  def test_acceptance_criteria
    validate_field(:acceptance_criteria, true, nil, 4096)
  end

  # Test the validation of effort.  Note: Effort should equal the sum of the tasks' efforts if nil.
  def test_effort
    assert_failure(:effort, 'a')
    
    story = stories(:first)
    assert_equal 1, story.effort
    story.effort=nil
    story.save(false)
    assert_equal 5, story.effort
  end

  # Test the validation of status.
  def test_status_code
    assert_success( :status_code, 0)
    assert_failure( :status_code, -1 )
    assert_failure( :status_code, 3 )
  end

  # Test that added stories are put at the end of the list.
  def test_priority_on_add
    assert_equal [3, 2, 1] << create_story.id, Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test successfully sorting the stories.
  def test_sort_success
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    Story.sort([1, 2, 3]).each {|story| story.save(false)}
    assert_equal [1, 2, 3], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end

  # Test failure to change the sort order.
  def test_sort_failure
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
    assert_raise(ActiveRecord::RecordNotFound) {
      Story.sort [999, 2, 3]
    }
    assert_equal [3, 2, 1], Story.find(:all, :order=>'priority').collect {|story| story.id}    
  end
  
  # Test deleting an story (should delete tasks).
  def test_delete_story
    assert_equal tasks(:one).story, stories(:first)
    stories(:first).destroy
    assert_nil Task.find_by_name('test')
  end

private

  # Create a story with valid values.  Options will override default values (should be :attribute => value).
  def create_story(options = {})
    Story.create({ :name => 'foo', :description => 'bar', :effort => 5.0, :acceptance_criteria => 'must',
      :status_code => 0 }.merge(options))
  end
end