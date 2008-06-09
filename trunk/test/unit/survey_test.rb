require File.dirname(__FILE__) + '/../test_helper'

class SurveyTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :stories
  fixtures :surveys
  fixtures :survey_mappings

  # Test that a survey can be created.
  def test_create_survey
    assert_difference 'Survey.count' do
      survey = create_survey
      assert !survey.new_record?, "#{survey.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of email.
  def test_email
    assert_failure(:email, nil)
    assert_failure(:email, 'a@b.c')  # bad if 5 long (plus last bit must be two characters)
    assert_success(:email, 'a@b.ce') # ok if 6 long
    assert_failure(:email, 'a@b.ce') # no duplicates
    assert_failure(:email, 'A@b.ce') # no duplicates (case doesn't matter)
    assert_success(:email, 'a@abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcd.com')  # 100 ok
    assert_failure(:email, 'a@abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijkabcd.com') # 101 not so much
    assert_failure(:email, 'aaaaaa')
    assert_failure(:email, 'aaa@aa')
    assert_failure(:email, 'aa @a.aa')
    assert_failure(:email, 'test@foo.com') # in use
    assert_failure(:email, 'Test@foo.com') # case doesn't matter
  end

  # Test the validation of exclude.
  def test_excluded
    survey = create_survey
    assert_equal false, survey.excluded # Defaults to false
    assert_success( :excluded, true)
    assert_success( :excluded, false )
  end

  # Test summarization.
  def test_summarize
    surveys(:first).apply_to_stories.each do |story|
      story.save(false)
    end
    assert_equal 1.0, stories(:first).user_priority
    assert_equal 1.0, stories(:second).user_priority
    assert_equal 2.0, stories(:third).user_priority
  end

  # Test deleting a survey
  def test_delete_survey
    assert_equal survey_mappings(:first).survey, surveys(:first)
    surveys(:first).destroy
    assert_nil SurveyMapping.find_by_id(1)
  end

private

  # Create a survey with valid values.  Options will override default values (should be :attribute => value).
  def create_survey(options = {})
    Survey.create({ :project_id => 1, :email => 'foo'+rand.to_s+'@bar.com' }.merge(options))
  end
end
