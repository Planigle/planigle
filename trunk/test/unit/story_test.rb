require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < Test::Unit::TestCase
  fixtures :stories

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

  # Test the validation of effort.
  def test_effort
    assert_failure(:effort, 'a')
  end

  # Test the validation of status code.
  def test_status_code
    # Test that we can leave out the status code.
    assert_difference get_count do
      obj = Story.create({ :name => 'foo', :description => 'bar', :effort => 5.0, :acceptance_criteria => 'must'})
      assert !obj.new_record?, "#{obj.errors.full_messages.to_sentence}"
    end

    assert_failure(:status_code,-1)
    assert_success(:status_code, 0)
    assert_success(:status_code, 2)
    assert_failure(:status_code, 3)
  end

  # Test the validation of status.
  def test_status
    assert_equal stories(:first).status, Story.valid_status_values[stories(:first).status_code]
    stories(:first).status = 'Accepted'
    assert_equal stories(:first).status, 'Accepted'
  end

  # Test the xml created for stories.
  def test_xml
    story = stories(:first)
    assert_tag( story, :status, story.status )
    assert_no_tag( story, :status_code )
  end
  
private

  # Create a story with valid values.  Options will override default values (should be :attribute => value).
  def create_story(options = {})
    Story.create({ :name => 'foo', :description => 'bar', :effort => 5.0, :acceptance_criteria => 'must',
      :status_code=> 0}.merge(options))
  end
end