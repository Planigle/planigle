require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < ActiveSupport::TestCase
  fixtures :companies
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
    assert_difference 'Company.count' do
      company = create_company
      assert !company.new_record?, "#{company.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test deleting a company
  def test_delete_company
    assert_equal projects(:first).company, companies(:first)
    assert_equal teams(:first).project, projects(:first)
    assert_equal individuals(:aaron).company, companies(:first)
    assert_equal individuals(:admin2).company, companies(:first)
    assert_equal releases(:first).project, projects(:first)
    assert_equal iterations(:first).project, projects(:first)
    assert_equal stories(:first).project, projects(:first)
    assert_equal surveys(:first).project, projects(:first)
    assert_equal story_attributes(:first).project, projects(:first)
    companies(:first).destroy
    assert_nil Project.find_by_id(1)
    assert_nil Team.find_by_id(1)
    assert_nil Individual.find_by_id(6).company
    assert_nil Release.find_by_id(1)
    assert_nil Iteration.find_by_id(1)
    assert_nil Story.find_by_id(1)
    assert_nil Survey.find_by_id(1)
    assert_nil StoryAttribute.find_by_id(1)
    assert_nil Individual.find_by_id(2) # non-admin deleted
    assert Individual.find_by_id(6) # admin set to nil
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal Company.count, Company.get_records(individuals(:quentin)).length
    assert_equal 1, Company.get_records(individuals(:aaron)).length
    assert_equal 1, Company.get_records(individuals(:user)).length
    assert_equal 1, Company.get_records(individuals(:readonly)).length
  end

private

  # Create a company with valid values.  Options will override default values (should be :attribute => value).
  def create_company(options = {})
    Company.create({ :name => 'foo' }.merge(options))
  end
end
