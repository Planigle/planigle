require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexReleasesTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :releases
  fixtures :iterations
  fixtures :audits

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto(ENV['test_host']+"/index.html", "Main") 
    sleep 1 # Wait to ensure remember me check is made
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test selection.
  def test_a_select
    init('admin2')
    select_release
  end

  # Test create (in one stream for more efficiency).
  def test_create
    init('admin2')
    create_release_failure
    create_release_success
    create_release_cancel
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    edit_release_failure
    edit_release_success
  end

  # Test canceling edit.
  def test_edit_cancel
    init('admin2')
    edit_release_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_release_cancel
    delete_release
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert @ie.button("releaseBtnCreate").visible
    assert @ie.button("releaseBtnEdit")[1].visible
    assert @ie.button("releaseBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert !@ie.button("releaseBtnCreate").visible
    assert !@ie.button("releaseBtnEdit")[1].visible
    assert !@ie.button("releaseBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert !@ie.button("releaseBtnCreate").visible
    assert !@ie.button("releaseBtnEdit")[1].visible
    assert !@ie.button("releaseBtnDelete")[1].visible
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("releaseBtnEdit")[1].click
    @ie.button("releaseBtnInfo").click
    assert_equal 4, @ie.button_bar("mainNavigation").selectedIndex
    assert_equal 0, @ie.data_grid("changeGrid").num_rows
  end

private

  # Test whether error handling works for creating an release.
  def create_release_failure
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnCreate").click
    
    # Values will be based off of last release (non-numeric name)
    assert_equal '', @ie.text_area("releaseFieldName").text
    assert_equal '09/13/2008', @ie.text_area("releaseFieldStart").text
    assert_equal '12/14/2008', @ie.text_area("releaseFieldFinish").text

    create_release('', '05/28/2008', '08/28/2008')
    @ie.button("releaseBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("releaseError").text
    assert_equal '', @ie.text_area("releaseFieldName").text
    assert_equal '05/28/2008', @ie.text_area("releaseFieldStart").text
    assert_equal '08/28/2008', @ie.text_area("releaseFieldFinish").text
    assert_not_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnCancel").click
  end
    
  # Test whether you can successfully create an release.
  def create_release_success
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnCreate").click
    
    # Values will be based off of last release (non-numeric name)
    assert_equal '', @ie.text_area("releaseFieldName").text
    assert_equal '09/13/2008', @ie.text_area("releaseFieldStart").text
    assert_equal '12/14/2008', @ie.text_area("releaseFieldFinish").text
    
    create_release('foo 1.0', '05/28/2008', '08/28/2008')
    @ie.button("releaseBtnChange").click

    # Since last release ends in a number, name will be incremented.
    assert_equal 'Release was successfully created.', @ie.text_area("releaseError").text
    assert_equal 'foo 1.1', @ie.text_area("releaseFieldName").text
    assert_equal '08/29/2008', @ie.text_area("releaseFieldStart").text
    assert_equal '11/28/2008', @ie.text_area("releaseFieldFinish").text
    assert_not_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("releaseResourceGrid").num_rows
    assert_equal "foo 1.0,5/28/2008,8/28/2008,Edit | Delete", @ie.data_grid("releaseResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("releaseBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of an release.
  def create_release_cancel
    # Delete current releases to see what happens with default values.
    Release.find(:all).each{|release| release.destroy}
    
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnCreate").click
    create_release('foo', '05/28/2008', '08/28/2008')
    @ie.button("releaseBtnCancel").click
    assert_equal '', @ie.text_area("releaseError").text
    assert_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
  end

  # Create an release.
  def create_release(name, start, length)
    @ie.text_area("releaseFieldName").input(:text => name )
    @ie.text_area("releaseFieldStart").input(:text => start )
    @ie.text_area("releaseFieldFinish").input(:text => length )
  end
    
  # Test whether error handling works for editing an release.
  def edit_release_failure
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    edit_release(' ', '05/28/2008', '8/28/2008')
    @ie.button("releaseBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("releaseError").text
    assert_equal ' ', @ie.text_area("releaseFieldName").text
    assert_equal '05/28/2008', @ie.text_area("releaseFieldStart").text
    assert_equal '08/28/2008', @ie.text_area("releaseFieldFinish").text
    assert_not_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnCancel").click
  end
    
  # Test whether you can successfully edit an release.
  def edit_release_success
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    edit_release('foo 1', '05/28/2008', '08/28/2008')
    @ie.button("releaseBtnChange").click
    assert_equal '', @ie.text_area("releaseError").text
    assert_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
    assert_equal "foo 1,5/28/2008,8/28/2008,Edit | Delete", @ie.data_grid("releaseResourceGrid").tabular_data
  end
    
  # Test whether you can successfully cancel editing an release.
  def edit_release_cancel
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    edit_release('foo', '05/28/2008', '08/28/2008')
    @ie.button("releaseBtnCancel").click
    assert_equal '', @ie.text_area("releaseError").text
    assert_nil @ie.button("releaseBtnCancel")
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
  end

  # Edit an release.
  def edit_release(name, start, length)
    @ie.button("releaseBtnEdit")[1].click
    @ie.text_area("releaseFieldName").input(:text => name )
    @ie.text_area("releaseFieldStart").input(:text => start )
    @ie.text_area("releaseFieldFinish").input(:text => length )
  end

  # Select a release to see what is displayed in iterations.
  def select_release
    @ie.data_grid("releaseResourceGrid").select(:item_renderer => "first")
    assert_equal 2, @ie.data_grid("iterationResourceGrid").num_rows
  end
    
  # Test deleting an release.
  def delete_release_cancel
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnDelete")[1].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("releaseError").text
    assert_equal num_rows, @ie.data_grid("releaseResourceGrid").num_rows
  end
    
  # Test deleting an release.
  def delete_release
    num_rows = @ie.data_grid("releaseResourceGrid").num_rows
    @ie.button("releaseBtnDelete")[1].click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("releaseError").text
    assert_equal num_rows-1, @ie.data_grid("releaseResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
    (0..2).each do |i|
      @ie.data_grid("releaseResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("releaseResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
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
    @ie.button_bar("mainNavigation").change(:related_object => "Schedule")
  end
end