require File.dirname(__FILE__) + '/../test_helper'

class Survey_MappingTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

  # Test that a survey_mapping can be created.
  def test_create_survey_mapping
    assert_difference 'SurveyMapping.count' do
      survey_mapping = create_surveymapping
      assert !survey_mapping.new_record?, "#{survey_mapping.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of priority.
  def test_priority
    assert_success(:priority, 0)
    assert_failure(:priority, 'a')
  end
  
  def test_name
    assert_equal "test", survey_mappings(:first).name
    assert_equal "test2", survey_mappings(:second).name
  end
  
  def test_description
    assert_equal "description", survey_mappings(:first).description
    assert_equal "", survey_mappings(:second).description
  end
  
  def test_normalized_priority
    assert_equal 1, survey_mappings(:first).normalized_priority
    assert_nil survey_mappings(:second).normalized_priority
  end

  # Test the xml created for survey mappings.
  def test_xml
    survey_mapping = survey_mappings(:first)
    assert_no_tag( survey_mapping, :id )
    assert_no_tag( survey_mapping, :survey_id )
  end

private

  # Create a survey_mapping with valid values.  Options will override default values (should be :attribute => value).
  def create_surveymapping(options = {})
    SurveyMapping.create({ :survey_id => 1, :story_id => 1, :priority => 1 }.merge(options))
  end
end
