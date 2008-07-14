require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexIndividualsTest < Test::Unit::TestCase
  fixtures :individuals
  fixtures :projects

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
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

  # Test creating unsuccessfully.
  def test_create_failure
    init('admin2')
    assert_equal Individual.count, @ie.data_grid("individualResourceGrid").num_rows
    create_individual_failure
  end 

  # Test creating successfully.
  def test_create_success
    init('admin2')
    create_individual_success
  end 

  # Test canceling create.
  def test_create_cancel
    init('admin2')
    create_individual_cancel
  end 

  # Test edit (in two streams for more efficiency).
  def test_edit_failure
    init('admin2')
    edit_individual_failure
    edit_individual_self
  end

  # Test edit (in two streams for more efficiency).
  def test_edit_success
    init('admin2')
    edit_individual_success
  end 

  # Test edit (in two streams for more efficiency).
  def test_edit_success
    init('admin2')
    edit_individual_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_individual_cancel
    delete_individual
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    project_grid
    assert @ie.button("individualBtnCreate").visible
    row = find_row('aaron') + 1
    assert @ie.button("individualBtnEdit")[row].visible
    assert @ie.button("individualBtnDelete")[row].visible
    verify_create
    verify_edit(false)
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    project_grid
    assert !@ie.button("individualBtnCreate").visible
    assert !@ie.button("individualBtnDelete")[find_row('user')-1].visible
    verify_edit(true)
    row = find_row('readonly')-1
    assert !@ie.button("individualBtnEdit")[row].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    project_grid
    assert !@ie.button("individualBtnCreate").visible
    row = find_row('readonly')-1
    assert !@ie.button("individualBtnEdit")[row].visible
    assert !@ie.button("individualBtnDelete")[row].visible
  end

private

  # Test whether error handling works for creating an individual.
  def create_individual_failure
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnCreate").click

    assert_equal 'Project Admin', @ie.combo_box("individualFieldRole").text
    
    create_individual('Test', ' ', 'testit', 'testit', 'testy2@testit.com', 'testy', 'test', 'Admin', 'true')
    @ie.button("individualBtnChange").click

    # Values should not change
    assert_equal "Login can't be blank\rLogin is too short (minimum is 2 characters)", @ie.text_area("individualError").text
    assert_equal 'Test', @ie.combo_box("individualFieldProject").text
    assert_equal ' ', @ie.text_area("individualFieldLogin").text
    assert_equal 'testit', @ie.text_area("individualFieldPassword").text
    assert_equal 'testit', @ie.text_area("individualFieldPasswordConfirmation").text
    assert_equal 'testy2@testit.com', @ie.text_area("individualFieldEmail").text
    assert_equal 'testy', @ie.text_area("individualFieldFirstName").text
    assert_equal 'test', @ie.text_area("individualFieldLastName").text
    assert_equal 'Admin', @ie.combo_box("individualFieldRole").text
    assert_equal 'true', @ie.combo_box("individualFieldEnabled").text
    assert_not_nil @ie.button("individualBtnCancel")
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnCancel").click
  end
    
  # Test whether you can successfully create an individual.
  def create_individual_success
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnCreate").click
    
    create_individual('Test', 'testy2', 'testit', 'testit', 'testy2@testit.com', 'testy', 'test', 'Admin', 'true')
    @ie.button("individualBtnChange").click

    sleep 5 # Wait for results
    assert_equal 'Individual was successfully created.', @ie.text_area("individualError").text
    assert_equal 'Test', @ie.combo_box("individualFieldProject").text
    assert_equal '', @ie.text_area("individualFieldLogin").text
    assert_equal '', @ie.text_area("individualFieldPassword").text
    assert_equal '', @ie.text_area("individualFieldPasswordConfirmation").text
    assert_equal '', @ie.text_area("individualFieldEmail").text
    assert_equal '', @ie.text_area("individualFieldFirstName").text
    assert_equal '', @ie.text_area("individualFieldLastName").text
    assert_equal 'Project Admin', @ie.combo_box("individualFieldRole").text
    assert_equal 'true', @ie.combo_box("individualFieldEnabled").text
    assert_not_nil @ie.button("individualBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("individualResourceGrid").num_rows
    assert_equal "Test,testy2,testy2@testit.com,testy,test,Admin,false,true,Edit | Delete", @ie.data_grid("individualResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("individualBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of an individual.
  def create_individual_cancel
    # Delete current individuals to see what happens with default values.
    Individual.find(:all).each{|individual| individual.destroy}
    
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnCreate").click
    create_individual('Test', 'testy2', 'testit', 'testit', 'testy2@testit.com', 'testy', 'test', 'Admin', 'true')
    @ie.button("individualBtnCancel").click
    assert_equal '', @ie.text_area("individualError").text
    assert_nil @ie.button("individualBtnCancel")
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
  end

  # Create an individual.
  def create_individual(project, login, password, password_confirmation, email, first_name, last_name, role, enabled)
    @ie.combo_box("individualFieldProject").open
    @ie.combo_box("individualFieldProject").select(:item_renderer => project )
    @ie.text_area("individualFieldLogin").input(:text => login )
    @ie.text_area("individualFieldPassword").input(:text => password )
    @ie.text_area("individualFieldPasswordConfirmation").input(:text => password_confirmation )
    @ie.text_area("individualFieldEmail").input(:text => email )
    @ie.text_area("individualFieldFirstName").input(:text => first_name )
    @ie.text_area("individualFieldLastName").input(:text => last_name )
    @ie.combo_box("individualFieldRole").open
    @ie.combo_box("individualFieldRole").select(:item_renderer => role )
    @ie.combo_box("individualFieldEnabled").open
    @ie.combo_box("individualFieldEnabled").select(:item_renderer => enabled )
  end
    
  # Test whether error handling works for editing an individual.
  def edit_individual_failure
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    edit_individual(find_row('ted'), 'Test', ' ', 'testit', 'testit', 'testy3@testit.com', 'testy', 'test', 'Project Admin', 'true')
    @ie.button("individualBtnChange").click

    assert_equal "Login can't be blank\rLogin is too short (minimum is 2 characters)", @ie.text_area("individualError").text
    assert_equal 'Test', @ie.combo_box("individualFieldProject").text
    assert_equal ' ', @ie.text_area("individualFieldLogin").text
    assert_equal 'testit', @ie.text_area("individualFieldPassword").text
    assert_equal 'testit', @ie.text_area("individualFieldPasswordConfirmation").text
    assert_equal 'testy3@testit.com', @ie.text_area("individualFieldEmail").text
    assert_equal 'testy', @ie.text_area("individualFieldFirstName").text
    assert_equal 'test', @ie.text_area("individualFieldLastName").text
    assert_equal 'Project Admin', @ie.combo_box("individualFieldRole").text
    assert_equal 'true', @ie.combo_box("individualFieldEnabled").text
    assert_not_nil @ie.button("individualBtnCancel")
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnCancel").click
  end
    
  # Test whether you can successfully edit an individual.
  def edit_individual_success
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    row = find_row('ted')
    edit_individual(row, 'Test', 'testy3', 'testit', 'testit', 'testy3@testit.com', 'testy', 'test', 'Project Admin', 'true')
    @ie.button("individualBtnChange").click
    assert_equal '', @ie.text_area("individualError").text
    assert_nil @ie.button("individualBtnCancel")
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
    assert_equal "Test,testy3,testy3@testit.com,testy,test,Project Admin,false,true,Edit | Delete", @ie.data_grid("individualResourceGrid").tabular_data(:start => row-1, :end => row-1)
  end
    
  # Test that you can't change your own role / enabledness.
  def edit_individual_self
    @ie.button("individualBtnEdit")[find_row('admin2')].click
    assert !@ie.form_item("individualFormRole").visible
    assert !@ie.form_item("individualFormEnabled").visible
    @ie.button("individualBtnCancel").click
  end
    
  # Test whether you can successfully cancel editing an individual.
  def edit_individual_cancel
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    edit_individual(find_row('ted'), 'Test', 'testy2', 'testit', 'testit', 'testy3@testit.com', 'testy', 'test', 'Project Admin', 'true')
    @ie.button("individualBtnCancel").click
    assert_equal '', @ie.text_area("individualError").text
    assert_nil @ie.button("individualBtnCancel")
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
  end

  # Edit an individual.
  def edit_individual(row, project, login, password, password_confirmation, email, first_name, last_name, role, enabled)
    @ie.button("individualBtnEdit")[row].click
    @ie.combo_box("individualFieldProject").open
    @ie.combo_box("individualFieldProject").select(:item_renderer => project )
    @ie.text_area("individualFieldLogin").input(:text => login )
    @ie.text_area("individualFieldPassword").input(:text => password )
    @ie.text_area("individualFieldPasswordConfirmation").input(:text => password_confirmation )
    @ie.text_area("individualFieldEmail").input(:text => email )
    @ie.text_area("individualFieldFirstName").input(:text => first_name )
    @ie.text_area("individualFieldLastName").input(:text => last_name )
    @ie.combo_box("individualFieldRole").open
    @ie.combo_box("individualFieldRole").select(:item_renderer => role )
    @ie.combo_box("individualFieldEnabled").open
    @ie.combo_box("individualFieldEnabled").select(:item_renderer => enabled )
  end
    
  # Test deleting an individual.
  def delete_individual_cancel
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnDelete")[find_row('ted')].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("individualError").text
    assert_equal num_rows, @ie.data_grid("individualResourceGrid").num_rows
  end
    
  # Test deleting an individual.
  def delete_individual
    num_rows = @ie.data_grid("individualResourceGrid").num_rows
    @ie.button("individualBtnDelete")[find_row('ted')].click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("individualError").text
    assert_equal num_rows-1, @ie.data_grid("individualResourceGrid").num_rows
  end
      
  # Test sorting the various columns.
  def sort_columns
    (0..7).each do |i|
      @ie.data_grid("individualResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("individualResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
    end
  end

  # Verify all users for project are shown.
  def project_grid
    assert_equal Individual.find_all_by_project_id(1, :conditions => "role != 0").length, @ie.data_grid("individualResourceGrid").num_rows
  end
  
  # Verify that the create panel doesn't show project, nor allow creation of admins.
  def verify_create
    @ie.button("individualBtnCreate").click
    assert !@ie.form_item("individualFormProject").visible
    assert_equal 'Project User', @ie.combo_box("individualFieldRole").text
    begin
      @ie.combo_box("individualFieldRole").open
      @ie.combo_box("individualFieldRole").select(:item_renderer => 'Admin' )     
      assert false # Should not get to this point
    rescue Exception
    end
  @ie.button("individualBtnCancel").click
  end

  # Verify that the edit panel doesn't show project, nor allow creation of admins.
  def verify_edit( is_self )
    @ie.button("individualBtnEdit")[find_row('user')].click
    assert !@ie.form_item("individualFormProject").visible
    if is_self
      assert !@ie.form_item("individualFormRole").visible
      assert !@ie.form_item("individualFormEnabled").visible
    else
      begin
        @ie.combo_box("individualFieldRole").open
        @ie.combo_box("individualFieldRole").select(:item_renderer => 'Admin' )     
        assert false # Should not get to this point
      rescue Exception
      end
    end
    @ie.button("individualBtnCancel").click
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
    sleep 6 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "People")
  end
  
  # Return the number of the row that contains the specified login.
  def find_row( login )
    (0..@ie.data_grid("individualResourceGrid").num_rows - 1).each do |i|
      row = @ie.data_grid("individualResourceGrid").tabular_data(:start => i, :end => i)
      columns = row.split(',')
      if columns[1] == login
        return i+1;
      end
    end
    return 1; # not found
  end
end