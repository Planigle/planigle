require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexStoriesTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :teams
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :criteria
  fixtures :story_attributes
  fixtures :story_attribute_values
  fixtures :story_values
  fixtures :tasks
  fixtures :audits

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto("http://localhost:3000/index.html", "Main") 
    sleep 1 # Wait to ensure remember me check is made
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test create failure.
  def test_create_failure
    init('admin2')
    create_story_failure
  end 

  # Test create success.
  def test_create_success
    init('admin2')
    create_story_success
  end 

  # Test create cancel.
  def test_create_cancel
    init('admin2')
    create_story_cancel
  end 

  # Test edit failure.
  def test_an_edit_failure
    init('admin2')
    edit_story_failure
  end 

  # Test edit success.
  def test_an_edit_success
    init('admin2')
    edit_story_success
  end 

  # Test edit cancel.
  def test_an_edit_cancel
    init('admin2')
    edit_story_cancel
  end 

  # Test editing multiple.
  def test_an_edit_multiple
    init('admin2')
    edit_single
    edit_multiple
  end 

  def test_a_split_failure
    init('admin2')
    split_story_failure
  end 

  def test_a_split_success_abort
    init('admin2')
    split_story_success_abort
  end 

  def test_a_split_success_no_abort
    init('admin2')
    split_story_success_no_abort
  end 

  def test_a_split_cancel
    init('admin2')
    split_story_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_story_cancel
    delete_story
    sort_columns
  end

  # Test deleting multiple.
  def test_z_misc_delete_multiple
    init('admin2')
    delete_single
    delete_multiple
    @ie.button("storyBtnCreate").click
    assert @ie.button("storyBtnEditAttributes").visible
  end 

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert @ie.button("storyBtnCreate").visible
    assert @ie.button("storyBtnEdit")[1].visible
    assert @ie.button("storyBtnDelete")[1].visible
    assert @ie.button("storyBtnMoveUp")[1].visible
    assert @ie.button("taskBtnAdd")[1].visible
    assert @ie.button("storyBtnSplit")[1].visible
    @ie.button("storyBtnCreate").click
    assert @ie.button("storyBtnEditAttributes").visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert @ie.button("storyBtnCreate").visible
    assert @ie.button("storyBtnEdit")[1].visible
    assert @ie.button("storyBtnDelete")[1].visible
    assert @ie.button("storyBtnMoveUp")[1].visible
    assert @ie.button("taskBtnAdd")[1].visible
    assert @ie.button("storyBtnSplit")[1].visible
    @ie.button("storyBtnCreate").click
    assert !@ie.button("storyBtnEditAttributes").visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert !@ie.button("storyBtnCreate").visible
    assert !@ie.button("storyBtnEdit")[1].visible
    assert !@ie.button("storyBtnDelete")[1].visible
    assert !@ie.button("storyBtnMoveUp")[1].visible
    assert !@ie.button("taskBtnAdd")[1].visible
    assert !@ie.button("storyBtnSplit")[1].visible
  end

  # Test changing custom attributes.
  def test_custom_attribute_add
    init('admin2')
    @ie.button("storyBtnCreate").click

    @ie.button("storyBtnEditAttributes").click
    @ie.button("editAttributeBtnAdd").click # Add a new number attribute: Beta
    @ie.text_area("editAttributeFieldName").input(:text => 'Beta' )
    @ie.combo_box("editAttributeFieldType").open
    @ie.combo_box("editAttributeFieldType").select(:item_renderer => 'Number' )
    @ie.button("editAttributeBtnOk").click
    sleep 2

    @ie.button("storyBtnEditAttributes").click
    @ie.button("editAttributeBtnAdd").click # Add a new listattribute: Gamma
    @ie.text_area("editAttributeFieldName").input(:text => 'Gamma' )
    @ie.combo_box("editAttributeFieldType").open
    @ie.combo_box("editAttributeFieldType").select(:item_renderer => 'List' )
    @ie.text_area("editValueFieldName").input(:text => 'Gamma' )
    @ie.button("editValueBtnAdd").click # Add a new value
    @ie.text_area("editValueFieldName").input(:text => 'Zeta' )
    @ie.button("editAttributeBtnOk").click
    sleep 2

    @ie.button("storyBtnEditAttributes").click
    @ie.button("editAttributeBtnAdd").click # Add a new listattribute: Theme
    @ie.text_area("editAttributeFieldName").input(:text => 'Theme' )
    @ie.combo_box("editAttributeFieldType").open
    @ie.combo_box("editAttributeFieldType").select(:item_renderer => 'List Per Release' )
    @ie.button("editValueBtnAdd").click # Add a new value
    @ie.text_area("editValueFieldName").input(:text => 'Do it' )
    @ie.button("editValueBtnAdd").click # Add a new value
    @ie.text_area("editValueFieldName").input(:text => 'Do it right' )
    @ie.combo_box("editAttributeRelease").open
    @ie.combo_box("editAttributeRelease").select(:item_renderer => 'second' )
    @ie.button("editValueBtnAdd").click # Add a new value
    @ie.text_area("editValueFieldName").input(:text => 'Do it fast' )
    @ie.button("editAttributeBtnOk").click
    sleep 2

    # Get first storyField number
    base = 0
    (10..100).each do |i|
      begin
        @ie.text_area("storyField" + i.to_s).input(:text => '5')
        base = i
        break
      rescue
      end
    end

    @ie.text_area("storyField" + base.to_s).input(:text => '5')

    @ie.combo_box("storyField" + (base + 1).to_s).click
    @ie.combo_box("storyField" + (base + 1).to_s).select(:item_renderer => 'Zeta')

    @ie.combo_box("storyFieldRelease").click
    @ie.combo_box("storyFieldRelease").select(:item_renderer => 'first')
    @ie.combo_box("storyField" + (base + 2).to_s).click
    @ie.combo_box("storyField" + (base + 2).to_s).select(:item_renderer => 'Do it right')
    @ie.combo_box("storyFieldRelease").click
    @ie.combo_box("storyFieldRelease").select(:item_renderer => 'No Release')    
    @ie.combo_box("storyField" + (base + 2).to_s).click
    begin
      @ie.combo_box("storyField" + (base + 2).to_s).select(:item_renderer => 'Do it right')
      assert false #shouldn't get to this point
    rescue Exception
    end
    @ie.combo_box("storyField" + (base + 2).to_s).click
    @ie.combo_box("storyField" + (base + 2).to_s).select(:item_renderer => 'None')
    @ie.combo_box("storyFieldRelease").select(:item_renderer => 'second')
    @ie.combo_box("storyField" + (base + 2).to_s).click
    @ie.combo_box("storyField" + (base + 2).to_s).select(:item_renderer => 'Do it fast')
    
    @ie.button("storyBtnChange").click
  end

  # Test changing custom attributes.
  def test_custom_attribute_delete
    init('admin2')
    @ie.button("storyBtnCreate").click
    @ie.button("storyBtnEditAttributes").click
    @ie.list("editAttributeAttributes").select(:item_renderer => 'Test_Number')
    @ie.button("editAttributeBtnDelete").click # Delete test_Number Attribute
    @ie.button("editAttributeBtnOk").click
    sleep 5

    assert_nil @ie.text_area("storyField3")
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("storyBtnEdit")[2].click
    @ie.button("storyBtnInfo").click
    assert_equal 4, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 2, @ie.data_grid("changeGrid").num_rows
  end
  
  # Test moving to the top
  def test_move_up
    init('admin2')
    @ie.button("storyBtnMoveUp")[2].click
    assert_equal ",test,first,Test_team,aaron hank,1,0,5,0,In Progress,true,1,2,description,-criteria\r-criteria2 (Done),first,test,testy,5,Value 1,Theme 1,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 0, :end => 0)
  end

  # Test clicking on the expand all button.
  def test_expand_all
    init('admin2')
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnExpandAll")[0].click
    assert_equal num_rows + 1, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnExpandAll")[0].click
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Test clicking on the select attributes button.
  def test_select_attributes
    init('admin2')
    @ie.button("storyBtnSelectAttributes")[0].click
    @ie.check_box("select_Description").click
    @ie.button("btn_ok").click
  end

private

  # Test whether error handling works for creating a story.
  def create_story_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("textArea")[0].text
    assert_equal '', @ie.text_area("textArea")[1].text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text

    create_story(' ', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    assert !@ie.form_item("storyFormReasonBlocked").visible
    @ie.button("storyBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("textArea")[0].text
    assert_equal 'Toggle Status,acceptance_criteria,Delete', @ie.data_grid("criteriaGrid").tabular_data(:start => 0, :end => 0)
    assert_equal 'fourth', @ie.combo_box("storyFieldIteration").text
    assert_equal 'second', @ie.combo_box("storyFieldRelease").text
    assert_equal 'Test_team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully create a story.
  def create_story_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("textArea")[0].text
    assert_equal '', @ie.text_area("textArea")[1].text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text
    
    create_story('foo', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Blocked', 'true', "custom", "Senate")
    @ie.button("storyBtnChange").click

    assert_equal 'Story was successfully created.', @ie.text_area("storyError").text
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("textArea")[0].text
    assert_equal '', @ie.text_area("textArea")[1].text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text
    assert_equal '', @ie.text_area("storyField1").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo,fourth,Test_team,ted williams,1,,,,Blocked,true,4,,description,acceptance_criteria,second,custom,,,None,None,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a story.
  def create_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    create_story('foo', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Create a story.
  def create_story(name, description, acceptance_criteria, iteration, release, team, owner, effort, status, public, custom="", reason_blocked="")
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("textArea")[0].input(:text => description )
    #@TODO: Would be good to test using the expanded text box here, but there is a bug where text fields
    # aren't accepted unless you go to another field.
    enter_criteria(acceptance_criteria)
    @ie.combo_box("storyFieldIteration").open
    @ie.combo_box("storyFieldIteration").select(:item_renderer => iteration )
    @ie.combo_box("storyFieldRelease").open
    @ie.combo_box("storyFieldRelease").select(:item_renderer => release )
    @ie.combo_box("storyFieldTeam").open
    @ie.combo_box("storyFieldTeam").select(:item_renderer => team )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    @ie.combo_box("storyFieldPublic").open
    @ie.combo_box("storyFieldPublic").select(:item_renderer => public )
    if reason_blocked != ""
      @ie.text_area("textArea")[1].input(:text => reason_blocked )
    end
    @ie.text_area("storyField1").input(:text => custom )
  end

  # Enter the acceptance criteria.
  def enter_criteria(acceptance_criteria)
    @ie.data_grid("criteriaGrid").edit(:rowIndex => "0", :columnIndex => "1")
    @ie.text_area("criteriaDescription").select_text(:beginIndex => "0", :endIndex => (@ie.text_area("criteriaDescription").length).to_s)
    @ie.text_area("criteriaDescription").input(:text => acceptance_criteria )
  end
    
  # Test whether error handling works for editing a story.
  def edit_story_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story(' ', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    assert !@ie.form_item("storyFormReasonBlocked").visible
    @ie.button("storyBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("textArea")[0].text
    assert_equal 'Toggle Status,acceptance_criteria,Delete', @ie.data_grid("criteriaGrid").tabular_data(:start => 0, :end => 0)
    assert_equal 'fourth', @ie.combo_box("storyFieldIteration").text
    assert_equal 'second', @ie.combo_box("storyFieldRelease").text
    assert_equal 'Test_team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully edit a story.
  def edit_story_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Blocked', 'true', "custom", "Fillibuster")
    @ie.button("storyBtnChange").click
    sleep 3 # Wait for results
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo 1,fourth,Test_team,ted williams,1,,,,Blocked,true,1,2,description,acceptance_criteria,second,custom,,,None,None,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 0, :end => 0)
  end
    
  # Test whether you can successfully cancel editing a story.
  def edit_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Edit a single story through the button at the top.
  def edit_single
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.button("storyBtnUpdateMultiple").click
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Edit multiple stories through the button at the top.
  def edit_multiple
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test3", :ctrl_key => "true")
    @ie.button("storyBtnUpdateMultiple").click
    assert_equal 'No Change', @ie.combo_box("updateFieldIteration").text
    assert_equal 'No Change', @ie.combo_box("updateFieldRelease").text
    assert_equal 'No Change', @ie.combo_box("updateFieldOwner").text
    assert_equal 'No Change', @ie.combo_box("updateFieldStatus").text
    assert_equal 'No Change', @ie.combo_box("updateFieldPublic").text
    @ie.combo_box("updateFieldIteration").open
    @ie.combo_box("updateFieldIteration").select(:item_renderer => 'fourth' )
    @ie.combo_box("updateFieldRelease").open
    @ie.combo_box("updateFieldRelease").select(:item_renderer => 'first' )
    @ie.combo_box("updateFieldTeam").open
    @ie.combo_box("updateFieldTeam").select(:item_renderer => 'Test_team' )
    @ie.combo_box("updateFieldOwner").open
    @ie.combo_box("updateFieldOwner").select(:item_renderer => 'aaron hank' )
    @ie.combo_box("updateFieldStatus").open
    @ie.combo_box("updateFieldStatus").select(:item_renderer => 'Blocked' )
    @ie.text_area("textArea").input(:text => 'President' )
    @ie.combo_box("updateFieldPublic").open
    @ie.combo_box("updateFieldPublic").select(:item_renderer => 'true' )
    @ie.combo_box("customField5").open
    @ie.combo_box("customField5").select(:item_renderer => 'Value 2' )
    @ie.combo_box("customField6").open
    @ie.combo_box("customField6").select(:item_renderer => 'Theme 2' )
    @ie.button("updateBtnOk").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",test,fourth,Test_team,aaron hank,1,0,5,0,Blocked,true,2,2,description,-criteria\r-criteria2 (Done),first,test,testy,5,Value 2,Theme 2,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 1, :end => 1)
    assert_equal ",test3,fourth,Test_team,aaron hank,1,,,,Blocked,true,1,2,,,first,,,,Value 2,Theme 2,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 0, :end => 0)
  end

  # Edit a story.
  def edit_story(name, description, acceptance_criteria, iteration, release, team, owner, effort, status, public, custom="", reason_blocked="")
    @ie.button("storyBtnEdit")[1].click
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("textArea")[0].input(:text => description )
    enter_criteria(acceptance_criteria)
    @ie.combo_box("storyFieldIteration").open
    @ie.combo_box("storyFieldIteration").select(:item_renderer => iteration )
    @ie.combo_box("storyFieldRelease").open
    @ie.combo_box("storyFieldRelease").select(:item_renderer => release )
    @ie.combo_box("storyFieldTeam").open
    @ie.combo_box("storyFieldTeam").select(:item_renderer => team )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    if reason_blocked != ""
      @ie.text_area("textArea")[1].input(:text => reason_blocked )
    end

    @ie.combo_box("storyFieldPublic").open
    @ie.combo_box("storyFieldPublic").select(:item_renderer => public )
    @ie.text_area("storyField1").input(:text => custom )
  end
    
  # Test whether error handling works for splitting a story.
  def split_story_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnSplit")[2].click
    assert_equal 'test', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("textArea")[0].text
    assert_equal 'Toggle Status,criteria,Delete', @ie.data_grid("criteriaGrid").tabular_data(:start => 0, :end => 0)
    assert_equal 'second', @ie.combo_box("storyFieldIteration").text
    assert_equal 'first', @ie.combo_box("storyFieldRelease").text
    assert_equal 'Test_team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'aaron hank', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    split_story(' ', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnChange").click
    @ie.alert("Abort").button("Yes").click
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("textArea")[0].text
    assert_equal 'Toggle Status,acceptance_criteria,Delete', @ie.data_grid("criteriaGrid").tabular_data(:start => 0, :end => 0)
    assert_equal 'fourth', @ie.combo_box("storyFieldIteration").text
    assert_equal 'second', @ie.combo_box("storyFieldRelease").text
    assert_equal 'Test_team', @ie.combo_box("storyFieldTeam").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully split a story (aborting the old story).
  def split_story_success_abort
    @ie.combo_box("itemStatus").open
    @ie.combo_box("itemStatus").select(:item_renderer => 'All Statuses' )
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnSplit")[2].click
    split_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnChange").click
    @ie.alert("Abort").button("Yes").click
    sleep 3 # Wait for results
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    rows = @ie.data_grid("storyResourceGrid").num_rows
    assert_equal num_rows + 1, rows
    assert_equal ",test,first,Test_team,aaron hank,0,0,2,0,Done,true,,,description,criteria2 (Done),first,test,testy,5,Value 1,Theme 1,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => rows-3, :end => rows-3)
    assert_equal ",foo 1,fourth,Test_team,ted williams,1,0,3,0,In Progress,true,2,,description,acceptance_criteria,second,test,testy,5,Value 1,None,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => rows-2, :end => rows-2)
  end
    
  # Test whether you can successfully split a story (without aborting).
  def split_story_success_no_abort
    @ie.combo_box("itemStatus").open
    @ie.combo_box("itemStatus").select(:item_renderer => 'All Statuses' )
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnSplit")[2].click
    split_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnChange").click
    @ie.alert("Abort").button("No").click
    sleep 3 # Wait for results
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    rows = @ie.data_grid("storyResourceGrid").num_rows
    assert_equal num_rows + 1, rows
    assert_equal ",test,first,Test_team,aaron hank,1,0,2,0,In Progress,true,2,2,description,-criteria\r-criteria2 (Done),first,test,testy,5,Value 1,Theme 1,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => rows-3, :end => rows-3)
    assert_equal ",foo 1,fourth,Test_team,ted williams,1,0,3,0,Not Started,true,3,,description,acceptance_criteria,second,test,testy,5,Value 1,None,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => rows-1, :end => rows-1)
  end
    
  # Test whether you can successfully cancel splitting a story.
  def split_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnSplit")[2].click
    split_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'Test_team', 'ted williams', '1', 'Not Started', 'true')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Split a story.
  def split_story(name, description, acceptance_criteria, iteration, release, team, owner, effort, status, public)
    @ie.text_area("storyFieldName").select_text(:beginIndex => "0", :endIndex => "4")
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("textArea")[0].select_text(:beginIndex => "0", :endIndex => "11")
    @ie.text_area("textArea")[0].input(:text => description )
    enter_criteria(acceptance_criteria)
    @ie.combo_box("storyFieldIteration").open
    @ie.combo_box("storyFieldIteration").select(:item_renderer => iteration )
    @ie.combo_box("storyFieldRelease").open
    @ie.combo_box("storyFieldRelease").select(:item_renderer => release )
    @ie.combo_box("storyFieldTeam").open
    @ie.combo_box("storyFieldTeam").select(:item_renderer => team )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    @ie.combo_box("storyFieldPublic").open
    @ie.combo_box("storyFieldPublic").select(:item_renderer => public )
  end
    
  # Test deleting a story.
  def delete_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[1].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Test deleting a story.
  def delete_story
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[1].click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-1, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Delte a single story through the button at the top.
  def delete_single
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.button("storyBtnDeleteMultiple").click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-1, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Delete multiple stories through the button at the top.
  def delete_multiple
    @ie.combo_box("itemStatus").open
    @ie.combo_box("itemStatus").select(:item_renderer => 'All Statuses' )
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test2")
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test3", :ctrl_key => "true")
    @ie.button("storyBtnDeleteMultiple").click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-2, @ie.data_grid("storyResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
    (1..11).each do |i|
      @ie.data_grid("storyResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("storyResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
    end
  end
      
  # Log in to the system with the specified credentials.
  def login( logon, password )
    @ie.text_area("userID").input(:text => logon )
    @ie.text_area("userPassword").input(:text => password )
    @ie.button("loginButton").click
  end
  
  # Initialize for a particular logon
  def init( logon )
    login(logon, 'testit')
    sleep 5 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "Stories")
    @ie.combo_box("team").open
    @ie.combo_box("team").select(:item_renderer => 'All Teams' )
  end
end