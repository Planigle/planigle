require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  fixtures :teams
  fixtures :individuals
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :projects
  fixtures :tasks
  fixtures :criteria
  fixtures :story_attributes
  fixtures :story_attribute_values
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
    assert_success(:acceptance_criteria, create_string(4096))
    assert_failure(:acceptance_criteria, create_string(4097), :criteria)
    story = create_story(:acceptance_criteria => "Criteria 1\nCriteria 2\nCriteria 3")
    assert_equal 3, story.reload.criteria.count
    assert_equal 'Criteria 1', story.criteria[0].description
    assert_equal 'Criteria 2', story.criteria[1].description
    assert_equal 'Criteria 3', story.criteria[2].description
    assert_equal "*Criteria 1\n*Criteria 2\n*Criteria 3", story.acceptance_criteria

    story.acceptance_criteria = "*Criteria 1\n*Criteria 2\n\n*Criteria 3"
    assert_equal 3, story.reload.criteria.count
    assert_equal 'Criteria 1', story.criteria[0].description
    assert_equal 'Criteria 2', story.criteria[1].description
    assert_equal 'Criteria 3', story.criteria[2].description
    assert_equal "*Criteria 1\n*Criteria 2\n*Criteria 3", story.acceptance_criteria
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
  
  # Test calculating the estimate from tasks.
  def test_estimate
    assert_equal 3, stories(:first).estimate
  end
  
  # Test calculating the effort from tasks.
  def test_calculated_effort
    assert_equal 5, stories(:first).time
  end
  
  # Test calculating the actual from tasks.
  def test_actual
    assert_equal 1, stories(:first).actual
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
  
  # Test changing my project.
  def test_project_id
    single_individ = Individual.create(:first_name => 'foo', :last_name => 'bar', :login => 'single' << rand.to_s, :email => 'single' << rand.to_s << '@example.com', :password => 'quired', :password_confirmation => 'quired', :role => 0, :company_id => 1, :project_ids => "1", :phone_number => '5555555555')
    multi_individ = Individual.create(:first_name => 'foo', :last_name => 'bar', :login => 'multiple' << rand.to_s, :email => 'multiple' << rand.to_s << '@example.com', :password => 'quired', :password_confirmation => 'quired', :role => 0, :company_id => 1, :project_ids => "1,3", :phone_number => '5555555555')
    story = create_story
    single_task = Task.create(:story_id => story.id, :name => 'test', :individual_id => single_individ.id)
    multi_task = Task.create(:story_id => story.id, :name => 'test', :individual_id => multi_individ.id)
    story.attributes={:custom_1 => 'foo', :custom_2 => 'bar', :custom_3 => 5, :custom_5 => 1}
    story.save(false)
    story.reload
    assert_equal 4, story.story_values.size

    story.attributes={:project_id => 3}
    story.save(false)
    assert_nil single_task.reload.individual_id
    assert_equal multi_individ.id, multi_task.reload.individual_id
    assert_equal 0, story.reload.story_values.size
  end
  
  # Test a custom attribute.
  def test_custom
    story = create_story(:custom_1 => 'test1')
    assert_equal 'test1', story.story_values.find(:first, :conditions => {:story_attribute_id => 1}).value
    story = create_story(:custom_2 => 'test2')
    assert_equal 'test2', story.story_values.find(:first, :conditions => {:story_attribute_id => 2}).value
    story = create_story(:custom_3 => '5')
    assert_equal '5', story.story_values.find(:first, :conditions => {:story_attribute_id => 3}).value
    story = create_story(:custom_10 => '5')
    assert_equal 1, story.errors.length
    assert_equal nil, story.story_values.find(:first, :conditions => {:story_attribute_id => 10})
  end
  
  # Test a custom list attribute.
  def test_custom_list
    story = create_story(:custom_5 => 1)
    assert_equal "1", story.story_values.find(:first, :conditions => {:story_attribute_id => 5}).value
    story_attribute_values(:first).destroy
    assert_nil story.story_values.find(:first, :conditions => {:story_attribute_id => 5})
  end
  
  # Test a custom list attribute with an invalid value.
  def test_custom_list_invalid
    story = create_story(:custom_5 => 6)
    assert_equal 1, story.errors.length
    assert_nil story.story_values.find(:first, :conditions => {:story_attribute_id => 6})
  end
  
  # Test a custom release list attribute.
  def test_custom_release_list
    story = create_story(:custom_6 => 4, :release_id => 1)
    assert_equal "4", story.story_values.find(:first, :conditions => {:story_attribute_id => 6}).value
    story_attribute_values(:fourth).destroy
    assert_nil story.story_values.find(:first, :conditions => {:story_attribute_id => 6})
  end
  
  # Test a custom release list attribute with an invalid value.
  def test_custom_release_list_invalid
    story = create_story(:custom_6 => 7)
    assert_equal 1, story.errors.length
    assert_nil story.story_values.find(:first, :conditions => {:story_attribute_id => 6})
  end
  
  # Test a custom release list attribute with an invalid value.
  def test_custom_release_list_invalid_release
    story = create_story(:custom_6 => 6)
    assert_equal 1, story.errors.length
    assert_nil story.story_values.find(:first, :conditions => {:story_attribute_id => 6})
  end

  # Test the accepted? method.
  def test_accepted
    assert !stories(:first).accepted?
    assert stories(:second).accepted?
  end
  
  # Test the caption function.
  def test_caption

  assert_equal 'test<br/>In Progress - 1 of 2 tasks done', stories(:first).caption
  assert_equal 'test2<br/>Done', stories(:second).caption
  assert_equal 'test3<br/>In Progress', stories(:third).caption
  assert_equal 'test5<br/>Blocked - 0 of 1 task done', stories(:fifth).caption
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
    assert_equal [3, 2, 1, 4, 6] << create_story.id, Story.find(:all, :conditions => 'project_id = 1', :order=>'priority').collect {|story| story.id}    
  end
  
  # Test deleting an story (should delete tasks).
  def test_delete_story
    assert_equal criteria(:first).story, stories(:first)
    assert_equal tasks(:one).story, stories(:first)
    assert_equal survey_mappings(:first).story, stories(:first)
    assert_equal story_values(:first).story, stories(:first)
    stories(:first).destroy
    assert_nil Criterium.find_by_description('test_ac')
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
    assert_equal Story.find_all_by_project_id(1).length - 1, Story.get_records(individuals(:aaron)).length
    assert_equal Story.find_all_by_project_id(1).length - 1, Story.get_records(individuals(:user)).length
    assert_equal Story.find_all_by_project_id(1).length - 1, Story.get_records(individuals(:readonly)).length
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :iteration_id => 1}).length, Story.get_records(individuals(:readonly), {:iteration_id => iterations(:first).id}).length
  end
  
  # Test finding individuals for a specific user.
  def test_find_not_done
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :status_code => [0,1,2]}).length - 1, Story.get_records(individuals(:readonly), {:status_code => 'NotDone'}).length
  end
  
  # Test finding individuals for a specific user.
  def test_find_current_release
    assert_equal Story.find(:all, :conditions => {:project_id => 1}).length - 1, Story.get_records(individuals(:readonly), {:release_id => 'Current'}).length
    release = Release.create(:project_id => 1, :name => 'Test', :start => Date.today, :finish =>  Date.today + 14)
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :release_id => release.id}).length, Story.get_records(individuals(:readonly), {:release_id => 'Current'}).length
  end

  # Test finding individuals for a specific user.
  def test_find_current_iteration
    assert_equal Story.find(:all, :conditions => {:project_id => 1}).length - 1, Story.get_records(individuals(:readonly), {:iteration_id => 'Current'}).length
    iteration = Iteration.create(:project_id => 1, :name => 'Test', :start => Date.today, :finish =>  Date.today + 14)
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :iteration_id => iteration.id}).length, Story.get_records(individuals(:readonly), {:iteration_id => 'Current'}).length
  end

  # Test finding individuals for a specific user.
  def test_find_my_team
    assert_equal Story.find(:all, :conditions => {:project_id => 1, :team_id => individuals(:aaron).team_id}).length, Story.get_records(individuals(:aaron), {:team_id => 'MyTeam'}).length
    assert_equal Story.find(:all, :conditions => {:project_id => 1}).length - 1, Story.get_records(individuals(:readonly), {:team_id => 'MyTeam'}).length
  end

  # Test finding individuals for a specific user.
  def test_find_individual
    assert_equal 1, Story.get_records(individuals(:aaron), {:individual_id => individuals(:aaron).id}).length
    Task.create(:story_id => 3, :name => 'assigned', :individual_id => individuals(:aaron).id)
    assert_equal 2, Story.get_records(individuals(:aaron), {:individual_id => individuals(:aaron).id}).length
    assert_equal 3, Story.get_records(individuals(:aaron), {:individual_id => nil}).length
  end

  # Test finding epics for a specific user.
  def test_find_epics
    assert_equal 1, 1, Story.get_records(individuals(:aaron), {:view_epics => true}).length
    assert_equal 1, 1, Story.get_records(individuals(:aaron), {:view_epics => true, :iteration_id => 1}).length # iteration id ignored
  end

  # Test finding based on custom list attributes.
  def test_find_custom_list
    assert_equal 1, Story.get_records(individuals(:aaron), {:custom_5 => 1}).length
    assert_equal 0, Story.get_records(individuals(:aaron), {:custom_5 => 2}).length
    assert_equal 3, Story.get_records(individuals(:aaron), {:custom_5 => nil}).length
    assert_equal 1, Story.get_records(individuals(:aaron), {:custom_6 => 4}).length
    assert_equal 0, Story.get_records(individuals(:aaron), {:custom_6 => 5}).length
    assert_equal 3, Story.get_records(individuals(:aaron), {:custom_6 => nil}).length
    assert_equal 1, Story.get_records(individuals(:aaron), {:custom_5 => 1, :custom_6 => 4}).length
    assert_equal 0, Story.get_records(individuals(:aaron), {:custom_5 => 1, :custom_6 => 5}).length
  end

  # Test finding stories matching text.
  def test_find_text
    assert_equal 0, Story.get_records(individuals(:aaron), :text => 'teststring').length
    create_story(:name => 'TestString')
    assert_equal 1, Story.get_records(individuals(:aaron), :text => 'teststring').length
    create_story(:description => 'TestString')
    assert_equal 2, Story.get_records(individuals(:aaron), :text => 'teststring').length
    create_story(:reason_blocked => 'TestString')
    assert_equal 3, Story.get_records(individuals(:aaron), :text => 'teststring').length
    create_story(:acceptance_criteria => 'TestString')
    assert_equal 4, Story.get_records(individuals(:aaron), :text => 'teststring').length
    story = create_story(:custom_1 => 'TestString')
    assert_equal 5, Story.get_records(individuals(:aaron), :text => 'teststring').length
    create_story(:custom_2 => 'TestString')
    assert_equal 6, Story.get_records(individuals(:aaron), :text => 'teststring').length
    story = create_story
    story.tasks << Task.create(:name => 'TestString')
    assert_equal 7, Story.get_records(individuals(:aaron), :text => 'teststring').length
    story = create_story
    story.tasks << Task.create(:name => 'foo', :description => 'TestString')
    assert_equal 8, Story.get_records(individuals(:aaron), :text => 'teststring').length
    story = create_story
    story.tasks << Task.create(:name => 'foo', :reason_blocked => 'TestString')
    assert_equal 9, Story.get_records(individuals(:aaron), :text => 'teststring').length
    assert_equal 0, Story.get_records(individuals(:aaron), :text => 'otherstring').length
    
    assert_equal 1, Story.get_records(individuals(:aaron), :text => 's1')[0].id
    assert_equal 0, Story.get_records(individuals(:aaron), :text => 's300').length
    assert_equal 5, Story.get_records(individuals(:user2), :text => 't3')[0].id
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
    assert_equal "PID,Epic,Name,Description,Acceptance Criteria,Size,Estimate,To Do,Actual,Status,Reason Blocked,Release,Iteration,Team,Owner,Public,User Rank,Test_List,Test_Number,Test_Release,Test_String,Test_Text\nS3,\"\",test3,\"\",\"\",1.0,,,,In Progress,\"\",\"\",\"\",\"\",\"\",false,2.0,\"\",\"\",\"\",\"\"\,\"\"\nS2,\"\",test2,\"\",\"\",1.0,,,,Done,\"\",first,first,\"\",\"\",true,1.0,\"\",\"\",\"\",\"\",\"\"\nS1,Epic,test,description,\"*criteria\n*criteria2 (Done)\",1.0,3.0,5.0,1.0,In Progress,\"\",first,first,Test_team,aaron hank,true,2.0,Value 1,5,Theme 1,test,testy\nT1,\"\",test_task,,\"\",\"\",,3.0,,In Progress,,\"\",\"\",\"\",aaron hank,\"\",\"\",\"\",\"\",\"\",\"\",\"\"\nT2,\"\",test2_task,,\"\",\"\",3.0,2.0,1.0,Done,,\"\",\"\",\"\",aaron hank,\"\",\"\",\"\",\"\",\"\",\"\",\"\"\nS4,\"\",test4,\"\",\"\",1.0,,,,In Progress,\"\",\"\",\"\",\"\",\"\",true,,\"\",\"\",\"\",\"\",\"\"\n", string

    string = Story.export(individuals(:project_admin2))
    assert_equal "PID,Epic,Name,Description,Acceptance Criteria,Size,Estimate,To Do,Status,Reason Blocked,Release,Iteration,Team,Owner,Public,User Rank,Test_String2\nS5,\"\",test5,\"\",\"\",2.0,2.0,3.0,Blocked,\"\",\"\",\"\",\"\",\"\",true,,testit\nT3,\"\",test3,More,\"\",\"\",2.0,3.0,Blocked,,\"\",\"\",\"\",\"\",\"\",\"\",\"\"\n", string

    string = Story.export(individuals(:aaron), {:name => 'test3'})
    assert_equal "PID,Epic,Name,Description,Acceptance Criteria,Size,Estimate,To Do,Actual,Status,Reason Blocked,Release,Iteration,Team,Owner,Public,User Rank,Test_List,Test_Number,Test_Release,Test_String,Test_Text\nS3,\"\",test3,\"\",\"\",1.0,,,,In Progress,\"\",\"\",\"\",\"\",\"\",false,2.0,\"\",\"\",\"\",\"\"\,\"\"\n", string
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

  def test_import_new_task_existing_story
    scount = Story.count
    tcount = Task.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\n1,Fred\nt,Bob"))
    assert Story.find(:first, :conditions => ["name = 'Fred'"])
    assert Task.find(:first, :conditions => ["name = 'Bob'"])
    assert_equal scount, Story.count
    assert_equal tcount + 1, Task.count
  end

  def test_import_new_task_new_story
    scount = Story.count
    tcount = Task.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\n,Fred\nt,Bob"))
    assert Story.find(:first, :conditions => ["name = 'Fred'"])
    assert Task.find(:first, :conditions => ["name = 'Bob'"])
    assert_equal scount + 1, Story.count
    assert_equal tcount + 1, Task.count
  end

  def test_import_existing_task
    count = Task.count
    verify_no_errors(Story.import(individuals(:aaron), "pid,name\nT1,Fred"))
    assert_equal 'Fred', tasks(:one).reload.name
    assert_equal count, Task.count
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

  def test_import_custom_list
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_List\n1,value 1"))
    assert_equal "1", StoryValue.find(:first, :conditions => {:story_id => 1, :story_attribute_id => 5}).reload.value
  end

  def test_import_custom_list_invalid
    verify_errors(Story.import(individuals(:admin2), "pid,Test_List\n1,Bogus"))
  end

  def test_import_custom_list_none
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_List\n1,"))
    assert_equal 0, StoryValue.find(:all, :conditions => {:story_id => 1, :story_attribute_id => 5}).length
  end

  def test_import_custom_release_list
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_Release\n1,Theme 1"))
    assert_equal "4", StoryValue.find(:first, :conditions => {:story_id => 1, :story_attribute_id => 6}).reload.value
  end

  def test_import_custom_release_list_invalid
    verify_errors(Story.import(individuals(:admin2), "pid,Test_Release\n1,Bogus"))
  end

  def test_import_custom_release_list_invalid_release
    verify_errors(Story.import(individuals(:admin2), "pid,Test_Release\n1,Theme 3"))
  end

  def test_import_custom_release_list_none
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_Release\n1,"))
    assert_equal 0, StoryValue.find(:all, :conditions => {:story_id => 1, :story_attribute_id => 6}).length
  end

  def test_import_custom_create
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_String\n2,5"))
    assert_equal "5", StoryValue.find(:first, :conditions => {:story_id => 2, :story_attribute_id => 1}).reload.value
  end

  def test_import_custom_delete
    verify_no_errors(Story.import(individuals(:admin2), "pid,Test_String\n1,"))
    assert_nil StoryValue.find(:first, :conditions => {:story_id => 1, :story_attribute_id => 1})  
  end
  
  def test_value_for
    story = create_story(:name => 'test', :status_code => 1, :release_id => 1, :iteration_id => 1, :team_id => 1, :individual_id => 2, :is_public => true, :custom_1 => 'test1')
    assert_equal 'test1', story.value_for(story_attributes(:first)) # custom_1
    assert_equal 1, story.value_for(story_attributes(:std_1_13)) # Release
    assert_equal 1, story.value_for(story_attributes(:std_1_2)) # Iteration
    assert_equal 1, story.value_for(story_attributes(:std_1_3)) # Team
    assert_equal 2, story.value_for(story_attributes(:std_1_4)) # Owner
    assert_equal 1, story.value_for(story_attributes(:std_1_7)) # Status
    assert_equal 1, story.value_for(story_attributes(:std_1_8)) # Public

    story = create_story(:name => 'test2', :status_code => 0, :release_id => nil, :iteration_id => nil, :team_id => nil, :individual_id => nil, :is_public => false, :custom_1 => nil)
    assert_equal 0, story.value_for(story_attributes(:first)) # custom_1
    assert_nil story.value_for(story_attributes(:std_1_13)) # Release
    assert_nil story.value_for(story_attributes(:std_1_2)) # Iteration
    assert_nil story.value_for(story_attributes(:std_1_3)) # Team
    assert_nil story.value_for(story_attributes(:std_1_4)) # Owner
    assert_equal 0, story.value_for(story_attributes(:std_1_7)) # Status
    assert_equal 0, story.value_for(story_attributes(:std_1_8)) # Public
  end

  def test_relative_priority
    story = create_story
    story.attributes={:relative_priority => "3,2"}
    story.save(false)
    assert_equal 1.5, story.priority
  end
  
  def test_determine_priority
    story = create_story
    assert_equal 0, story.determine_priority("","3")
    assert_equal 1.5, story.determine_priority("","2")
    assert_equal 1.5, story.determine_priority("3","2")
    assert_equal 2.5, story.determine_priority("2","")
    assert_equal story.priority + 1, story.determine_priority(story.id.to_s,"")
  end
  
  def test_have_records_changed_no_changes
    sleep 1 # Distance from set up
    start = Time.now
    assert_no_changes(start)
  end
  
  def test_have_records_changed_story_changed
    assert_have_records_changed(stories(:fifth), stories(:first))
  end
  
  def test_have_records_changed_task_changed
    assert_have_records_changed(tasks(:three), tasks(:one))
  end
  
  def test_is_ready_to_accept
    story = stories(:first)
    assert !story.is_ready_to_accept
    task = tasks(:one)
    task.status_code = Story::Done
    task.save(false)
    story.reload
    assert story.is_ready_to_accept
  end
  
  def test_is_done
    assert !stories(:first).is_done
    assert stories(:second).is_done
  end
  
  def test_send_notification
    
  end
  
  def test_ready_to_accept_message
    assert_equal "All tasks for <a href='/?project_id=1&id=1'>test</a> are done.", stories(:first).ready_to_accept_message
  end
  
  def test_done_message
    assert_equal "<a href='/?project_id=1&id=1'>test</a> is done.", stories(:first).done_message
  end

  def test_matching_tasks
    story = stories(:first)
    story.current_conditions = {:individual_id => 2, :status_code => 1}
    assert_equal 1, story.filtered_tasks.length
    story.current_conditions = {:individual_id => 2, :status_code => 'NotDone'}
    assert_equal 1, story.filtered_tasks.length
    story.current_conditions = {:individual_id => 3, :status_code => 'NotDone'}
    assert_equal 0, story.filtered_tasks.length
    story.current_conditions = {:individual_id => nil, :status_code => 'NotDone'}
    assert_equal 0, story.filtered_tasks.length
  end
  
  def test_epics
    assert_equal 1, stories(:epic).stories.length
    assert_equal stories(:epic), stories(:first).epic
    assert_equal stories(:first), stories(:epic).stories[0]
  end
  
  def test_validate_epic
    story = stories(:first)
    story.story_id = -1
    story.save
    assert_equal 1, story.errors.length # invalid story id
    story.story_id = 5
    story.save
    assert_equal 1, story.errors.length # invalid project
  end

  def test_get_stats
    conditions={:status_code => '1'}
    stats = Story.get_stats(individuals(:aaron), conditions)
    assert_equal 0, stats[0][0]
    assert_equal 2, stats[0][1]
    assert_equal 0, stats[0][2]
    assert_equal 1, stats[0][3]
    assert_equal 0, stats[1][0]
    assert_equal 1, stats[1][1]
    assert_equal 0, stats[1][2]
    assert_equal 0, stats[1][3]
    assert_equal 0, stats[2][0]
    assert_equal 0, stats[2][1]
    assert_equal 0, stats[2][2]
    assert_equal 0, stats[2][3]
  end

private

  def assert_changes(start)
    assert Story.have_records_changed(individuals(:aaron), start)
  end

  def assert_no_changes(start)
    assert !Story.have_records_changed(individuals(:aaron), start)
  end
  
  def assert_have_records_changed(other_project_object, project_object)
    sleep 1 # Distance from set up
    start = Time.now
    other_project_object.name = "changed"
    other_project_object.save(false)
    assert_no_changes(start)

    project_object.name = "changed"
    project_object.save(false)
    assert_changes(start)

    project_object.destroy
    assert_changes(start)
  end

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