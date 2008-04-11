require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :stories
  fixtures :tasks

  # Test that a task can be created.
  def test_should_create_task
    assert_difference 'Task.count' do
      task = create_task
      assert !task.new_record?, "#{task.errors.full_messages.to_sentence}"
      assert_equal individuals(:quentin), task.individual # Tasks inherit the owner of their story.
    end
  end

  # Test that you can't create a task without a story.
  def test_create_task_without_story
    assert_no_difference 'Task.count' do
      task = Task.create({:name => 'foo', :description => 'bar', :effort => 5.0, :status_code => 0})
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

  # Test the validation of effort.
  def test_effort
    assert_failure(:effort, 'a')
  end

  # Test the validation of status code.
  def test_status_code
    assert_success( :status_code, 0)
    assert_failure( :status_code, -1 )
    assert_failure( :status_code, 3 )
  end

  # Test the accepted? method.
  def test_accepted
    assert !tasks(:one).accepted?
    assert tasks(:two).accepted?
  end

private

  # Create a task with valid values.  Options will override default values (should be :attribute => value).
  def create_task(options = {})
    Task.create({ :story_id => 1, :name => 'foo', :description => 'bar', :effort => 5.0,
      :status_code => 0 }.merge(options))
  end
end
