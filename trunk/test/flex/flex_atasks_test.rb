require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 
#Moved to beginning by preceding with an A.
class FlexAtasksTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :tasks
  fixtures :companies
  fixtures :projects
  fixtures :teams
  fixtures :individuals
  fixtures :stories
  fixtures :releases
  fixtures :iterations
  fixtures :story_attributes
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

  # Test create (in one stream for more efficiency).
  def test_create
    init('admin2')
    create_task_failure
    create_task_success
  end 

  # Test canceling create.
  def test_create_cancel
    init('admin2')
    create_task_cancel
  end 

  # Test editing multiple.
  def test_edit_multiple
    init('admin2')
    edit_single
    edit_multiple
  end 
  
  # Edit a single task through the button at the top.
  def edit_single
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test_task")
    @ie.button("storyBtnUpdateMultiple").click
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Edit multiple tasks through the button at the top.
  def edit_multiple
    @ie.combo_box("itemStatus").open
    @ie.combo_box("itemStatus").select(:item_renderer => 'All Statuses' )
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test_task")
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test2_task", :ctrl_key => "true")
    @ie.button("storyBtnUpdateMultiple").click
    assert_equal 'No Change', @ie.combo_box("updateFieldIteration").text
    assert_equal 'No Change', @ie.combo_box("updateFieldRelease").text
    assert_equal 'No Change', @ie.combo_box("updateFieldOwner").text
    assert_equal 'No Change', @ie.combo_box("updateFieldStatus").text
    assert_equal 'No Change', @ie.combo_box("updateFieldPublic").text
    @ie.combo_box("updateFieldOwner").open
    @ie.combo_box("updateFieldOwner").select(:item_renderer => 'aaron hank' )
    @ie.combo_box("updateFieldStatus").open
    @ie.combo_box("updateFieldStatus").select(:item_renderer => 'Not Started' )
    @ie.button("updateBtnOk").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",test2_task,,,aaron hank,,2,Not Started, , , ,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 3, :end => 3)
    assert_equal ",test_task,,,aaron hank,,3,Not Started, , , ,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 4, :end => 4)
  end

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    assert_equal Story.count(:conditions => ['project_id = ? and status_code < 2', projects(:first).id]) + Task.count(:conditions => ['story_id = ? and status_code < 3', stories(:first).id]), @ie.data_grid("storyResourceGrid").num_rows
    edit_task_failure
    edit_task_success
  end 

  # Test canceling edit.
  def test_edit_cancel
    init('admin2')
    edit_task_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_task_cancel
    delete_task
    sort_columns
  end

  # Test logging in as a story admin
  def test_project_admin
    init('aaron')
    @ie.button("storyBtnExpand")[1].click # In position 1 in some cases
    assert_equal Story.count(:conditions => ['project_id = ? and status_code < 2', projects(:first).id]) + Task.count(:conditions => ['story_id = ? and status_code < 3', stories(:first).id]), @ie.data_grid("storyResourceGrid").num_rows
    assert @ie.button("taskBtnAdd")[2].visible
    assert @ie.button("storyBtnEdit")[3].visible
    assert @ie.button("storyBtnDelete")[3].visible
  end

  # Test logging in as a story user
  def test_project_user
    init('user')
    assert_equal Story.count(:conditions => ['project_id = ? and status_code < 2', projects(:first).id]) + Task.count(:conditions => ['story_id = ? and status_code < 3', stories(:first).id]), @ie.data_grid("storyResourceGrid").num_rows
    assert @ie.button("taskBtnAdd")[2].visible
    assert @ie.button("storyBtnEdit")[3].visible
    assert @ie.button("storyBtnDelete")[3].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert_equal Story.count(:conditions => ['project_id = ? and status_code < 2', projects(:first).id]) + Task.count(:conditions => ['story_id = ? and status_code < 3', stories(:first).id]), @ie.data_grid("storyResourceGrid").num_rows
    assert !@ie.button("taskBtnAdd")[2].visible
    assert !@ie.button("storyBtnEdit")[3].visible
    assert !@ie.button("storyBtnDelete")[3].visible
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("storyBtnEdit")[4].click
    @ie.button("storyBtnInfo").click
    assert_equal 4, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 1, @ie.data_grid("changeGrid").num_rows
  end

private

  # Test whether error handling works for creating a task.
  def create_task_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("taskBtnAdd")[2].click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert !@ie.text_area("storyFormAcceptanceCriteria").visible
    assert !@ie.combo_box("storyFormIteration").visible
    assert !@ie.combo_box("storyFormRelease").visible
    assert !@ie.button("storyBtnEditAttributes").visible
    assert_equal 'aaron hank', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert !@ie.combo_box("storyFormPublic").visible

    create_task(' ', 'description', 'ted williams', '1', 'Not Started')
    assert !@ie.form_item("storyFormReasonBlocked").visible
    @ie.button("storyBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("storyFieldDescription").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully create a task.
  def create_task_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("taskBtnAdd")[2].click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert_equal 'aaron hank', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    
    create_task('foo', 'description', 'ted williams', '1', 'Blocked', "House")
    @ie.button("storyBtnChange").click

    assert_equal 'Task was successfully created.', @ie.text_area("storyError").text
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert_equal 'aaron hank', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo,,,ted williams,,1,Blocked, , , ,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 2, :end => 2)
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a task.
  def create_task_cancel
    # Delete current tasks to see what happens with default values.
    Project.find(:all).each{|task| task.destroy}
    
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("taskBtnAdd")[2].click
    create_task('foo', 'description', 'ted williams', '1', 'Not Started')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Create a task.
  def create_task(name, description, owner, effort, status, reason_blocked="")
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("storyFieldDescription").input(:text => description )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    if reason_blocked != ""
      @ie.text_area("storyFieldReasonBlocked").input(:text => reason_blocked )
    end
  end
    
  # Test whether error handling works for editing a task.
  def edit_task_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_task(' ', 'description', 'ted williams', '1', 'Not Started')
    assert !@ie.form_item("storyFormReasonBlocked").visible
    @ie.button("storyBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("storyFieldDescription").text
    assert !@ie.text_area("storyFormAcceptanceCriteria").visible
    assert !@ie.combo_box("storyFormIteration").visible
    assert !@ie.combo_box("storyFormRelease").visible
    assert !@ie.button("storyBtnEditAttributes").visible
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Not Started', @ie.combo_box("storyFieldStatus").text
    assert !@ie.combo_box("storyFormPublic").visible
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully edit a task.
  def edit_task_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_task('foo 1', 'description', 'ted williams', '1', 'Blocked', "House")
    @ie.button("storyBtnChange").click
    sleep 3 # Wait for results
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo 1,,,ted williams,,1,Blocked, , , ,Edit | Delete | Move To Top | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 2, :end => 2)
  end
    
  # Test whether you can successfully cancel editing a task.
  def edit_task_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_task('foo 1', 'description', 'ted williams', '1', 'Not Started')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Edit a task.
  def edit_task(name, description, owner, effort, status, reason_blocked="")
    @ie.button("storyBtnEdit")[4].click
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("storyFieldDescription").input(:text => description )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    if reason_blocked != ""
      @ie.text_area("storyFieldReasonBlocked").input(:text => reason_blocked )
    end
  end
    
  # Test deleting a task.
  def delete_task_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[4].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
    
  # Test deleting a task.
  def delete_task
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[4].click
    @ie.alert("Delete")[0].button("Yes").click
    sleep 1 # Wait for it to take effect.
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-1, @ie.data_grid("storyResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
    (1..10).each do |i|
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
    sleep 3 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "Stories")
    @ie.combo_box("team").open
    @ie.combo_box("team").select(:item_renderer => 'All Teams' )
    sleep 2
    @ie.button("storyBtnExpand")[3].click
  end
end