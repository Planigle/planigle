require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :teams
  fixtures :individuals
  fixtures :releases
  fixtures :iterations
  fixtures :story_attributes
  fixtures :stories
  fixtures :surveys

  # Test that an project can be created.
  def test_create_project
    assert_difference 'Project.count' do
      project = create_project
      assert !project.new_record?, "#{project.errors.full_messages.to_sentence}"
      assert_equal 13, project.story_attributes.length
    end
  end

  def test_company_id
    assert_failure(:company_id, nil)
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test the validation of survey_mode.
  def test_survey_mode
    project = create_project
    assert_equal 0, project.survey_mode # Defaults to Private (0)
    assert_success( :survey_mode, 0)
    assert_failure( :survey_mode, -1 )
    assert_failure( :survey_mode, 3 )
  end

  # Test the validation of premium_expiry.
  def test_premium_expiry
    assert_success(:premium_expiry, Date.today)
    assert_equal Date.today + 30, create_project().premium_expiry
  end

  # Test the validation of premium_limit.
  def test_premium_limit
    assert_failure( :premium_limit, nil )
    assert_failure( :premium_limit, 0 )
    assert_failure( :premium_limit, 1.5 )
    assert_success( :premium_limit, 1 )
  end

  # Test deleting an project
  def test_delete_project
    assert_equal teams(:first).project, projects(:first)
    assert_equal individuals(:aaron).project, projects(:first)
    assert_equal individuals(:admin2).project, projects(:first)
    assert_equal releases(:first).project, projects(:first)
    assert_equal iterations(:first).project, projects(:first)
    assert_equal stories(:first).project, projects(:first)
    assert_equal surveys(:first).project, projects(:first)
    assert_equal story_attributes(:first).project, projects(:first)
    projects(:first).destroy
    assert_nil Team.find_by_id(1)
    assert_nil Individual.find_by_id(6).project
    assert_nil Release.find_by_id(1)
    assert_nil Iteration.find_by_id(1)
    assert_nil Story.find_by_id(1)
    assert_nil Survey.find_by_id(1)
    assert_nil StoryAttribute.find_by_id(1)
    assert_nil Individual.find_by_id(2).project
    assert Individual.find_by_id(6) # admin set to nil
  end

  # Test the xml created for surveys.
  def test_create_survey
    survey = projects(:first).create_survey
    assert_tag( survey, :stories)
    assert_tag( survey, :story)
    assert_tag( survey, :id)
    assert_tag( survey, :name)
    assert_tag( survey, :description)
    assert_tag( survey, :priority)
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal Project.count, Project.get_records(individuals(:quentin)).length
    assert_equal 2, Project.get_records(individuals(:aaron)).length
    assert_equal 2, Project.get_records(individuals(:user)).length
    assert_equal 2, Project.get_records(individuals(:readonly)).length
    assert_equal 1, Project.get_records(individuals(:project_admin2)).length
    assert_equal 1, Project.get_records(individuals(:user2)).length
    assert_equal 1, Project.get_records(individuals(:ro2)).length
  end
  
  # Validate is_premium.
  def test_is_premium
    assert projects(:first).is_premium
    assert !projects(:second).is_premium
  end

private

  # Create an project with valid values.  Options will override default values (should be :attribute => value).
  def create_project(options = {})
    Project.create({ :company_id => 1, :name => 'foo' }.merge(options))
  end
end
