require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :individuals
  fixtures :iterations
  fixtures :stories

  # Test that an project can be created.
  def test_create_project
    assert_difference 'Project.count' do
      project = create_project
      assert !project.new_record?, "#{project.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test deleting an project
  def test_delete_project
    assert_equal individuals(:aaron).project, projects(:first)
    assert_equal iterations(:first).project, projects(:first)
    assert_equal stories(:first).project, projects(:first)
    projects(:first).destroy
    assert_nil Individual.find_by_id(2)
    assert_nil Iteration.find_by_id(1)
    assert_nil Story.find_by_id(1)
  end

private

  # Create an project with valid values.  Options will override default values (should be :attribute => value).
  def create_project(options = {})
    Project.create({ :name => 'foo' }.merge(options))
  end
end
