require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexIterationsTest < Test::Unit::TestCase
  fixtures :individuals
  fixtures :projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks

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
    create_iteration_failure
    create_iteration_success
    create_iteration_cancel
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    edit_iteration_failure
    edit_iteration_success
    edit_iteration_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    plan_iteration
    delete_iteration_cancel
    delete_iteration
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert @ie.button("iterationBtnCreate").visible
    assert @ie.button("iterationBtnEdit")[1].visible
    assert @ie.button("iterationBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert !@ie.button("iterationBtnCreate").visible
    assert !@ie.button("iterationBtnEdit")[1].visible
    assert !@ie.button("iterationBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert !@ie.button("iterationBtnCreate").visible
    assert !@ie.button("iterationBtnEdit")[1].visible
    assert !@ie.button("iterationBtnDelete")[1].visible
  end

private

  # Test whether error handling works for creating an iteration.
  def create_iteration_failure
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnCreate").click
    
    # Values will be based off of last iteration (non-numeric name)
    assert_equal '', @ie.text_area("iterationFieldName").text
    assert_equal '04/30/2008', @ie.text_area("iterationFieldStart").text
    assert_equal '3', @ie.text_area("iterationFieldLength").text

    create_iteration('', '05/28/2008', '2')
    @ie.button("iterationBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("iterationError").text
    assert_equal '', @ie.text_area("iterationFieldName").text
    assert_equal '05/28/2008', @ie.text_area("iterationFieldStart").text # Based on last iteration
    assert_equal '2', @ie.text_area("iterationFieldLength").text         # Based on last iteration
    assert_not_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnCancel").click
  end
    
  # Test whether you can successfully create an iteration.
  def create_iteration_success
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnCreate").click
    
    # Values will be based off of last iteration (non-numeric name)
    assert_equal '', @ie.text_area("iterationFieldName").text
    assert_equal '04/30/2008', @ie.text_area("iterationFieldStart").text
    assert_equal '3', @ie.text_area("iterationFieldLength").text
    
    create_iteration('foo 1', '05/28/2008', '2')
    @ie.button("iterationBtnChange").click

    # Since last iteration ends in a number, name will be incremented.
    assert_equal 'Iteration was successfully created.', @ie.text_area("iterationError").text
    assert_equal 'foo 2', @ie.text_area("iterationFieldName").text
    assert_equal '06/11/2008', @ie.text_area("iterationFieldStart").text
    assert_equal '2', @ie.text_area("iterationFieldLength").text
    assert_not_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("iterationResourceGrid").num_rows
    assert_equal "foo 1,5/28/2008,2,Plan | Edit | Delete", @ie.data_grid("iterationResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("iterationBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of an iteration.
  def create_iteration_cancel
    # Delete current iterations to see what happens with default values.
    Iteration.find(:all).each{|iteration| iteration.destroy}
    
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnCreate").click
    create_iteration('foo', '05/28/2008', '2')
    @ie.button("iterationBtnCancel").click
    assert_equal '', @ie.text_area("iterationError").text
    assert_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
  end

  # Create an iteration.
  def create_iteration(name, start, length)
    @ie.text_area("iterationFieldName").input(:text => name )
    @ie.text_area("iterationFieldStart").input(:text => start )
    @ie.text_area("iterationFieldLength").input(:text => length )
  end
    
  # Test whether error handling works for editing an iteration.
  def edit_iteration_failure
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    edit_iteration(' ', '05/28/2008', '2')
    @ie.button("iterationBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("iterationError").text
    assert_equal ' ', @ie.text_area("iterationFieldName").text
    assert_equal '05/28/2008', @ie.text_area("iterationFieldStart").text
    assert_equal '2', @ie.text_area("iterationFieldLength").text
    assert_not_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnCancel").click
  end
    
  # Test whether you can successfully edit an iteration.
  def edit_iteration_success
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    edit_iteration('foo 1', '05/28/2008', '2')
    @ie.button("iterationBtnChange").click
    assert_equal '', @ie.text_area("iterationError").text
    assert_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
    assert_equal "foo 1,5/28/2008,2,Plan | Edit | Delete", @ie.data_grid("iterationResourceGrid").tabular_data
  end
    
  # Test whether you can successfully cancel editing an iteration.
  def edit_iteration_cancel
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    edit_iteration('foo', '05/28/2008', '2')
    @ie.button("iterationBtnCancel").click
    assert_equal '', @ie.text_area("iterationError").text
    assert_nil @ie.button("iterationBtnCancel")
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
  end

  # Edit an iteration.
  def edit_iteration(name, start, length)
    @ie.button("iterationBtnEdit")[1].click
    @ie.text_area("iterationFieldName").input(:text => name )
    @ie.text_area("iterationFieldStart").input(:text => start )
    @ie.text_area("iterationFieldLength").input(:text => length )
  end
    
  # Test deleting an iteration.
  def delete_iteration_cancel
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnDelete")[1].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("iterationError").text
    assert_equal num_rows, @ie.data_grid("iterationResourceGrid").num_rows
  end
    
  # Test deleting an iteration.
  def delete_iteration
    num_rows = @ie.data_grid("iterationResourceGrid").num_rows
    @ie.button("iterationBtnDelete")[1].click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("iterationError").text
    assert_equal num_rows-1, @ie.data_grid("iterationResourceGrid").num_rows
  end
    
  # Test selecting the plan button.
  def plan_iteration
    @ie.button("iterationBtnPlan")[1].click
    assert_equal 0, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 0, @ie.combo_box("iteration").selectedIndex
    @ie.button_bar("mainNavigation").change(:related_object => "Iterations")
  end
      
  # Test sorting the various columns.
  def sort_columns
    (0..2).each do |i|
      @ie.data_grid("iterationResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("iterationResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
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
    @ie.button_bar("mainNavigation").change(:related_object => "Iterations")
  end
end