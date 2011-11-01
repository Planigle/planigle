require File.dirname(__FILE__) + '/../test_helper'

class StoryAttributeTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :individuals
  fixtures :stories
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :individual_story_attributes
  fixtures :story_values

  # Test that a story attribute can be created.
  def test_create_story_attribute
    assert_difference 'StoryAttribute.count' do
      val = create_storyattribute
      assert !val.new_record?, "#{val.errors.full_messages.to_sentence}"
      assert_equal 210, val.ordering
      assert_equal false, val.show
      assert_equal true, val.is_custom
      assert_equal 65, val.width
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, 1, 40)
  end

  # Test the validation of type.
  def test_type
    validate_field(:value_type, false, nil, nil)
    assert_failure(:value_type, -1)
    assert_success(:value_type, 0)
    assert_success(:value_type, 4)
    assert_failure(:value_type, 5)
  end

  # Test the validation of ordering.
  def test_ordering
    assert_failure(:ordering, -1)
    assert_success(:ordering, 0)
    assert_success(:ordering, 1.5)
  end

  # Test the validation of show.
  def test_show
    assert_success(:show, true)
    assert_success(:show, false)
  end

  # Test the validation of width.
  def test_width
    assert_failure(:width, -1)
    assert_success(:width, 0)
    assert_success(:width, 1)
  end

  # Test the validation of is_custom.
  def test_is_custom
    assert_success(:is_custom, true)
    assert_success(:is_custom, false)
  end
  
  def test_values
    attrib = create_storyattribute(:value_type => 3, :values => "val 1,val 2,val 3")
    assert_equal 3, attrib.story_attribute_values.length
    val = attrib.story_attribute_values.find(:all, :conditions => {:value => 'val 1'})
    assert_equal 1, val.length
    assert_equal 1, attrib.story_attribute_values.find(:all, :conditions => {:value => 'val 2'}).length
    assert_equal 1, attrib.story_attribute_values.find(:all, :conditions => {:value => 'val 3'}).length

    attrib.update_values(["val 1","v2"])
    attrib.reload # Blow cache
    assert_equal 2, attrib.story_attribute_values.length
    val2 = attrib.story_attribute_values.find(:all, :conditions => {:value => 'val 1'})
    assert_equal 1, val2.length
    assert_equal val[0].id, val2[0].id
    assert_equal 1, attrib.story_attribute_values.find(:all, :conditions => {:value => 'v2'}).length
  end
  
  # Test updating existing values.
  def test_update_existing_values
    attrib = story_attributes(:fifth)
    attrib.attributes = {:values => '@1@replace,new'}
    val = attrib.story_attribute_values
    val.reload
    assert_equal 2, val.length
    assert_equal 1, val[0].id
    assert_equal 'replace', val[0].reload.value
    assert val[1].id > 3
    assert_equal 'new', val[1].value
  end
  
  # Test updating release values.
  def test_update_release_values
    attrib = story_attributes(:sixth)
    attrib.attributes = {:values => '@4@replace,1@new,@test'}
    val = attrib.story_attribute_values
    val.reload
    assert_equal 3, val.length
    assert_equal 4, val[0].id
    val[0].reload
    assert_equal 1, val[0].release_id
    assert_equal 'replace', val[0].value
    assert val[1].id > 5
    assert_equal 1, val[1].release_id
    assert_equal 'new', val[1].value
    assert val[2].id > 5
    assert_equal nil, val[2].release_id
    assert_equal 'test', val[2].value
  end

  # Test deleting a story attribute (should delete story attribute values).
  def test_delete_story_attribute
    assert_equal story_attribute_values(:first).story_attribute, story_attributes(:fifth)
    story_attributes(:fifth).destroy
    assert_nil StoryAttributeValue.find_by_id(1)
    assert_nil IndividualStoryAttribute.find_by_id(5)
  end
  
  def test_get_records_by_user
    attribs = StoryAttribute.get_records(individuals(:aaron))
    attrib = attribs.detect {|attrib| attrib.id == 34}
    assert_equal 40, attrib.width
    assert_equal 80, attrib.ordering
    assert_equal false, attrib.show

    attribs = StoryAttribute.get_records(individuals(:admin2))
    attrib = attribs.detect {|attrib| attrib.id == 34}
    assert_equal 45, attrib.width
    assert_equal 85, attrib.ordering
    assert_equal true, attrib.show
  end
  
  def test_get_records_new_user
    attribs = StoryAttribute.get_records(individuals(:quentin))
    attrib = attribs.detect {|attrib| attrib.id == 34}
    assert_equal 40, attrib.width
    assert_equal 80, attrib.ordering
    assert_equal false, attrib.show
  end
  
  def test_update_for
    attrib = story_attributes(:std_1_15)
    assert_equal 40, attrib.width
    assert_equal 80, attrib.ordering
    assert_equal false, attrib.show
    
    attrib.update_for(individuals(:aaron), {:width => 45, :ordering => 85, :show => true})
    attrib.show_for(individuals(:aaron))
    assert_equal 45, attrib.width
    assert_equal 85, attrib.ordering
    assert_equal true, attrib.show
  end

private

  # Create a story value with valid values.  Options will override default values (should be :attribute => value).
  def create_storyattribute(options = {})
    StoryAttribute.create({ :project_id => 1, :name => 'alpha', :value_type => 2}.merge(options))
  end
end