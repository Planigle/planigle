require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexCompaniesTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :companies
  fixtures :projects
  fixtures :individuals_projects
  fixtures :stories
  fixtures :iterations
  fixtures :tasks
  fixtures :audits
  fixtures :teams

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
    select_company
  end

  # Test create (in one stream for more efficiency).
  def test_create
    init('admin2')
    assert_equal Company.count, @ie.data_grid("projectResourceGrid").num_rows
    create_company_failure
    create_company_success
    create_company_cancel
  end 

  # Test edit (in one stream for more efficiency).
  def test_edit
    init('admin2')
    edit_company_failure
    edit_company_success
    edit_company_cancel
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_company_cancel
    delete_company
    sort_columns
  end

  # Test logging in as a project admin
  def test_project_admin
    init('pa2')
    assert_equal 2, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("teamBtnAdd")[1].visible
    assert @ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a project admin
  def test_project_admin_premium
    init('aaron')
    assert_equal 3, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert @ie.button("teamBtnAdd")[1].visible
    assert @ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user2')
    assert_equal 2, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user_premium
    init('user')
    assert_equal 3, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('ro2')
    assert_equal 2, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only_premium
    init('readonly')
    assert_equal 3, @ie.data_grid("projectResourceGrid").num_rows
    assert !@ie.button("projectBtnCreate").visible
    assert !@ie.button("teamBtnAdd")[1].visible
    assert !@ie.button("projectBtnEdit")[1].visible
    assert !@ie.button("projectBtnDelete")[1].visible
  end
  
  # Test showing the history
  def test_history
    init('admin2')
    @ie.button("projectBtnEdit")[1].click
    assert !@ie.button("projectBtnInfo").visible
  end

private

  # Test whether error handling works for creating a project.
  def create_company_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    
    assert_equal '', @ie.text_area("projectFieldName").text

    create_company(' ')
    @ie.button("projectBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal ' ', @ie.text_area("projectFieldName").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully create a project.
  def create_company_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    
    assert_equal '', @ie.text_area("projectFieldName").text
    
    create_company('company')

    @ie.button("projectBtnChange").click

    # Since last project ends in a number, name will be incremented.
    assert_equal 'Company was successfully created.', @ie.text_area("projectError").text
    assert_equal '', @ie.text_area("projectFieldName").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",company,,,Edit | Delete | Add Project", @ie.data_grid("projectResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a company.
  def create_company_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCreate").click
    create_company('company')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Create a company.
  def create_company(company)
    @ie.text_area("projectFieldName").input(:text => company )
  end
    
  # Test whether error handling works for editing a company.
  def edit_company_failure
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_company(' ')
sleep 5
    @ie.button("projectBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("projectError").text
    assert_equal ' ', @ie.text_area("projectFieldName").text
    assert_not_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnCancel").click
  end
    
  # Test whether you can successfully edit a company.
  def edit_company_success
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_company('company')

    @ie.button("projectBtnChange").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
    assert_equal ",company,,,Edit | Delete | Add Project", @ie.data_grid("projectResourceGrid").tabular_data
  end
    
  # Test whether you can successfully cancel editing a company.
  def edit_company_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    edit_company('company')
    @ie.button("projectBtnCancel").click
    assert_equal '', @ie.text_area("projectError").text
    assert_nil @ie.button("projectBtnCancel")
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end

  # Edit a company.
  def edit_company(company)
    @ie.button("projectBtnEdit")[1].click
    @ie.text_area("projectFieldName").input(:text => company )
  end

  # Select a company to see what is displayed in individuals.
  def select_company
    @ie.data_grid("projectResourceGrid").select(:item_renderer => "Test_company")
    assert_equal Individual.count(:conditions => {:company_id => 1}), @ie.data_grid("individualResourceGrid").num_rows
  end
    
  # Test deleting a company.
  def delete_company_cancel
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnDelete")[2].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("projectError").text
    assert_equal num_rows, @ie.data_grid("projectResourceGrid").num_rows
  end
    
  # Test deleting a company.
  def delete_company
    num_rows = @ie.data_grid("projectResourceGrid").num_rows
    @ie.button("projectBtnDelete")[2].click
    @ie.alert("Delete")[0].button("Yes").click
    sleep 2 # Wait for it to take effect.
    assert_equal '', @ie.text_area("projectError").text
    assert_equal num_rows-1, @ie.data_grid("projectResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
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
    @ie.button_bar("mainNavigation").change(:related_object => "People")
  end
end