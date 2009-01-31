require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  fixtures :teams
  fixtures :individuals
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :projects
  fixtures :tasks
  fixtures :story_attributes
  fixtures :story_values
  fixtures :surveys
  fixtures :survey_mappings

  # Test that a story can be created.
  def test_create_story
    assert_difference 'Story.count' do
      story = create_story
      assert !story.new_record?, "#{story.errors.full_messages.to_sentence}"
    end
  end

  # Test the validation of name.
  def test_name
    validate_field(:name, false, nil, 250)
  end

  # Test the validation of description.
  def test_description
    validate_field(:description, true, nil, 4096)
  end

  # Test the validation of acceptance criteria.
  def test_acceptance_criteria
    validate_field(:acceptance_criteria, true, nil, 4096)
  end

  # Test the validation of reason blocked.
  def test_reason_blocked
    validate_field(:reason_blocked, true, nil, 4096)
  end

  # Test the validation of priority.
  def test_priority
    assert_failure(:priority, 'a')
    assert_success(:priority, -1)
    assert_success(:priority, 0)
    assert_success(:priority, 1.345)
  end

  # Test the validation of effort.  Note: Effort should equal the sum of the tasks' efforts if nil.
  def test_effort
    assert_failure(:effort, 'a')
    assert_failure(:effort, -1)
    assert_success(:effort, 0)
    
    story = stories(:first)
    assert_equal 1, story.effort
    story.effort=nil
    story.save(false)
    assert_nil story.effort
    assert_equal 5, story.time
  end
  
  # Test calculating the effort from tasks.
  def test_calculated_effort
    assert_equal 5, stories(:first).time
  end

  # Test the validation of status.
  def test_status_code
    assert_success( :status_code, 0)
    assert_failure( :status_code, -1)
    assert_success( :status_code, 3)    
    assert_failure( :status_code, 4)    
  end

  # Test the validation of is_public.
  def test_is_public
    assert_success( :is_public, true)
    assert_success( :is_public, false)
  end
  
  # Test a custom attribute.
  def test_custom
    assert_success(:custom_1, "test")
    story = create_story(:custom_2 => 'testy')
    assert_equal 'testy', StoryValue.find(:first, :conditions => {:story_id => story.id, :story_attribute_id => 2}).value
  end

  # Test the accepted? method.
  def test_accepted
    assert !stories(:first).accepted?
    assert stories(:second).accepted?
  end
  
  # Test the caption function.
  def test_caption
    assert_equal 'test - In Progress', stories(:first).caption
  end
  
  # Test the url function.
  def test_url
    assert_equal '/planigle/stories/1', stories(:first).url
  end
  
  # Test splitting a story.
  def test_split
    story = stories(:first).split
    assert_equal 'test Part Two', story.name
    assert_equal 1, story.project_id
    assert_equal 2, story.individual_id
    assert_equal 2, story.iteration_id
    assert_equal 'description', story.description
    assert_equal 'criteria', story.acceptance_criteria
    assert_equal 1, story.effort
    assert_equal 0, story.status_code
  end
  
  # Test splitting a story where the story ends up in the backlog.
  def test_split_last
    story = create_story(:iteration_id => 4, :release_id => 1 ).split
    assert_equal 'foo Part Two', story.name
    assert_equal 1, story.project_id
    assert_equal nil, story.individual_id
    assert_equal nil, story.iteration_id
    assert_equal 'bar', story.description
    assert_equal 'must', story.acceptance_criteria
    assert_equal 5, story.effort
    assert_equal 0, story.status_code
  end
  
  # Test splitting a story where the story starts in the backlog.
  def test_split_backlog
    story = create_story(:iteration_id => nil ).split
    assert_equal 'foo Part Two', story.name
    assert_equal 1, story.project_id
    assert_equal nil, story.individual_id
    assert_equal nil, story.iteration_id
    assert_equal 'bar', story.description
    assert_equal 'must', story.acceptance_criteria
    assert_equal 5, story.effort
    assert_equal 0, story.status_code
  end
  
  # Test splitting a story where the direct effort is null.
  def test_split_null_effort
    story = stories(:first)
    story.effort = nil
    story.save(false)
    assert_nil story.effort
    assert_equal 5, story.time # Total of tasks
    story = story.split
    assert_nil story.time
  end

  # Test that added stories are put at the end of the list.
  def test_priority_on_add
    assert_equal [3, 2, 1, 4] << create_story.id, Story.find(:all, :conditions => 'project_id = 1', :order=>'priority').collect {|story| story.id}    
  end
  
  # Test deleting an story (should delete tasks).
  def test_delete_story
    assert_equal tasks(:one).story, stories(:first)
    assert_equal survey_mappings(:first).story, stories(:first)
    assert_equal story_values(:first).story, stories(:first)
    stories(:first).destroy
    assert_nil Task.find_by_name('test')
    assert_nil SurveyMapping.find_by_id('1')
    assert_nil StoryValue.find_by_id('1')
  end

  # Test that we can get a mapping of status to code.
  def test_status_code_mapping
    mapping = Story.status_code_mapping
    assert_equal 0, mapping['Not Started']
  end

  # Test finding individuals for a specific user.
  def test_find
    assert_equal 0, Story.get_records(individuals(:quentin)).length
    assert_equal Story.find_all_by_project_id(1).length, Story.get_records(individuals(:aaron)).length
    assert_equal Story.find_all_by_project_id(1).length, Story.get_records(individuals(:user)).length
    assert_equal Story.find_all_by_project_id(1).length, Story.get_records(individuals(:readonly)).length
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :iteration_id => 1}).length, Story.get_records(individuals(:readonly), iterations(:first).id).length
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :iteration_id => 1, :status_code => 1}).length, Story.get_records(individuals(:readonly), iterations(:first).id, ['stories.status_code = ?', 1]).length
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :status_code => 1}).length, Story.get_records(individuals(:readonly), nil, ['stories.status_code = ?', 1]).length
  end
  
  # Validate is_blocked.
  def test_is_blocked
    assert !stories(:first).is_blocked
    assert stories(:fifth).is_blocked
    assert stories(:fifth).blocked_message
  end

  # Validate export.
  def test_export
    string = Story.export(individuals(:aaron))
    assert_equal "PID,Name,Description,Acceptance Criteria,Size,Time,Status,Reason Blocked,Release,Iteration,Team,Owner,Public,User Rank,Test_Number,Test_String,Test_Text\n3,test3,\"\",\"\",1.0,,In Progress,,\"\",\"\",\"\",\"\",false,2.0,\"\",\"\",\"\"\n2,test2,\"\",\"\",1.0,,Done,,first,first,\"\",\"\",true,1.0,\"\",\"\",\"\"\n1,test,description,criteria,1.0,5.0,In Progress,,first,first,Test_team,aaron hank,true,2.0,5,test,testy\n4,test4,\"\",\"\",1.0,,In Progress,,\"\",\"\",\"\",\"\",true,,\"\",\"\",\"\"\n", string
  end

  def test_import_invalid_id
    name = stories(:first).name
    verify_errors(Story.import(individuals(:aaron), "pid,name\n9999,Fred"))
    assert_equal name, stories(:first).reload.name
  end

  def test_import_existing_story
    count = Story.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\n1,Fred"))
    assert_equal 'Fred', stories(:first).reload.name
    assert_equal count, Story.count
  end

  def test_import_new_story
    count = Story.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\n,Fred"))
    assert Story.find(:first, :conditions => ["name = 'Fred'"])
    assert_equal count + 1, Story.count
  end

  def test_import_non_relational_attributes
    count = Story.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name,description,acceptance criteria,size,status,reason blocked,public\n,Fred,description,acceptance,1,Blocked,because I said so,false"))
    story = Story.find(:first, :conditions => ["name = 'Fred'"])
    assert story
    assert_equal count + 1, Story.count
    assert_equal 'description', story.description
    assert_equal 'acceptance', story.acceptance_criteria
    assert_equal 1, story.effort
    assert_equal 'because I said so', story.reason_blocked
    assert_equal false, story.is_public
  end

  def test_import_blank_name
    name = stories(:first).name
    verify_errors(Story.import(individuals(:aaron), "pid,name\n1,"))
    assert_equal name, stories(:first).reload.name
  end

  def test_import_extra column
    verify_errors(Story.import(individuals(:aaron), "pid,name,foo\n1,Fred,"))
    assert_equal 'Fred', stories(:first).reload.name
  end

  def test_import_irregular_shape
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\n1,Fred,"))
    assert_equal 'Fred', stories(:first).reload.name
  end

  def test_import_valid_team
    verify_no_errors(Story.import(individuals(:aaron), "pid,team\n1,Test2"))
    assert_equal 'Test2', stories(:first).team.reload.name
  end

  def test_import_invalid_team
    name = stories(:first).team.name
    verify_errors(Story.import(individuals(:aaron), "pid,team\n1,Bogus"))
    assert_equal name, stories(:first).team.reload.name
  end

  def test_import_valid_individual
    verify_no_errors(Story.import(individuals(:aaron), "pid,owner\n1,user williams"))
    assert_equal 'user williams', stories(:first).individual.reload.name
  end

  def test_import_invalid_individual
    name = stories(:first).individual.name
    verify_errors(Story.import(individuals(:aaron), "pid,owner\n1,Bogus"))
    assert_equal name, stories(:first).individual.reload.name
  end

  def test_import_valid_release
    verify_no_errors(Story.import(individuals(:aaron), "pid,release\n1,second"))
    assert_equal 'second', stories(:first).release.reload.name
  end

  def test_import_valid_main_release
    release = releases(:second)
    release.name='1.0'
    release.save(false)
    verify_no_errors(Story.import(individuals(:aaron), "pid,release\n1,1"))
    assert_equal '1.0', stories(:first).release.reload.name
  end

  def test_import_invalid_release
    name = stories(:first).release.name
    verify_errors(Story.import(individuals(:aaron), "pid,release\n1,Bogus"))
    assert_equal name, stories(:first).release.reload.name
  end

  def test_import_valid_iteration
    verify_no_errors(Story.import(individuals(:aaron), "pid,iteration\n1,second"))
    assert_equal 'second', stories(:first).iteration.reload.name
  end

  def test_import_invalid_iteration
    name = stories(:first).iteration.name
    verify_errors(Story.import(individuals(:aaron), "pid,iteration\n1,Bogus"))
    assert_equal name, stories(:first).iteration.reload.name
  end

  def test_import_valid_status_code
    verify_no_errors(Story.import(individuals(:aaron), "pid,status\n1,Done"))
    assert_equal Story::Done, stories(:first).reload.status_code
  end

  def test_import_invalid_status_code
    status = stories(:first).status_code
    verify_errors(Story.import(individuals(:aaron), "pid,status\n1,Bogus"))
    assert_equal status, stories(:first).reload.status_code
  end

  def test_import_security
    name = stories(:first).name
    verify_errors(Story.import(individuals(:readonly), "pid,name\n1,Fred"))
    assert_equal name, stories(:first).reload.name
  end

  def test_import_custom_update
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_String\n1,5"))
    assert_equal "5", StoryValue.find(:first, :conditions => {:story_id => 1, :story_attribute_id => 1}).reload.value
  end

  def test_import_custom_create
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_String\n2,5"))
    assert_equal "5", StoryValue.find(:first, :conditions => {:story_id => 2, :story_attribute_id => 1}).reload.value
  end

  def test_import_custom_delete
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_String\n1,"))
    assert_nil StoryValue.find(:first, :conditions => {:story_id => 1, :story_attribute_id => 1})  
  end

private

  # Create a story with valid values.  Options will override default values (should be :attribute => value).
  def create_story(options = {})
    Story.create({ :name => 'foo', :description => 'bar', :effort => 5.0, :acceptance_criteria => 'must',
      :status_code => 0, :project_id => 1 }.merge(options))
  end
  
  # Check to ensure that there are no errors.
  def verify_no_errors(errors)
    errors.each do |err|
      if err.full_messages.length>0
        assert false
      end
    end
  end
  
  # Check to ensure that there are errors.
  def verify_errors(errors)
    err = false
    errors.each do |err2|
      if err2.full_messages.length>0
        err = true
      end
    end
    assert err
  end
end