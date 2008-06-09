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

private

  # Create a survey_mapping with valid values.  Options will override default values (should be :attribute => value).
  def create_surveymapping(options = {})
    SurveyMapping.create({ :survey_id => 1, :story_id => 1, :priority => 1 }.merge(options))
  end
end
