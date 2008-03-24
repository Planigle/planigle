require File.dirname(__FILE__) + '/../test_helper'
require 'individuals_controller'

# Re-raise errors caught by the controller.
class IndividualsController; def rescue_action(e) raise e end; end

class IndividualsControllerTest < Test::Unit::TestCase
  fixtures :individuals

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = IndividualsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @id = individuals(:quentin).id
  end

  # Test activating a user.
  def test_should_activate_user
    assert_nil Individual.authenticate('aaron', 'testit')
    get :activate, :activation_code => individuals(:aaron).activation_code
    assert_redirected_to '/'
    assert_equal individuals(:aaron), Individual.authenticate('aaron', 'testit')
  end

  # Test activation without a key.
  def test_should_not_activate_user_without_key
    get :activate
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  # Test activation with a blank key.
  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_redirected_to '/'
  rescue ActionController::RoutingError
    # well played, sir
  end

  # Test getting a listing of individuals without credentials.
  def test_index_unauthorized
    get :index
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting a listing of individuals.
  def test_index_success
    login_as(individuals(:quentin))
    get :index
    assert_response :success
    assert_template 'index'
  end

  # Test getting the form to create a new individual without credentials.
  def test_new_unauthorized
    get :new
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting the form to create a new individual.
  def test_new_success
    login_as(individuals(:quentin))
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:individual)
  end

  # Test creating a new individual without credentials.
  def test_create_unauthorized
    num_individuals = Individual.count
    post :create, :individual => { :login => 'foo', :password => 'testit', :password_confirmation => 'testit',
      :last_name => 'bar', :first_name => 'foo', :email => 'foo@bogus.com'}
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_equal num_individuals, Individual.count
  end

  # Test successfully creating a new individual.
  def test_create_success
    login_as(individuals(:quentin))
    num_individuals = Individual.count
    post :create, :individual => { :login => 'foo', :password => 'testit', :password_confirmation => 'testit',
      :last_name => 'bar', :first_name => 'foo', :email => 'foo@bogus.com'}
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_equal num_individuals + 1, Individual.count
  end

  # Test creating a new individual unsuccessfully.
  def test_create_failure
    login_as(individuals(:quentin))
    num_individuals = Individual.count
    post :create, :individual => { :login => 'foo' }
    assert_response :success
    assert_template 'new'
    assert_equal num_individuals, Individual.count
  end

  # Test showing an individual without credentials.
  def test_show_unauthorized
    get :show, :id => @id
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully showing an individual.
  def test_show_success
    login_as(individuals(:quentin))
    get :show, :id => @id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:individual)
    assert assigns(:individual).valid?
  end

  # Test getting the form to edit an individual without credentials.
  def test_edit_unauthorized
    get :edit, :id => @id
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting the form to edit an individual.
  def test_edit_success
    login_as(individuals(:quentin))
    get :edit, :id => @id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:individual)
    assert assigns(:individual).valid?
  end

  # Test updating an individual without credentials.
  def test_update_unauthorized
    new_email = 'todd'
    post :update, :id => @id, :individual => {:email => new_email}
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert individuals(:quentin).reload.email != new_email
  end

  # Test succcessfully updating an individual.
  def test_update_success
    login_as(individuals(:quentin))
    new_email = 'foo@bar.com'
    post :update, :id => @id, :individual => {:email => new_email}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @id
    assert_equal new_email, individuals(:quentin).reload.email
  end

  # Test updating an individual where the update fails.
  def test_update_failure
    login_as(individuals(:quentin))
    new_email = 'todd'
    post :update, :id => @id, :individual => {:email => new_email}
    assert_response :success
    assert_template 'edit'
    assert individuals(:quentin).reload.email != new_email
  end

  # Test deleting an individual without credentials.
  def test_destroy_unauthorized
    post :destroy, :id => @id
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_nothing_raised {
      Individual.find(@id)
    }
  end
    
  # Test successfully deleting an individual.
  def test_destroy_success
    login_as(individuals(:quentin))
    post :destroy, :id => @id
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_raise(ActiveRecord::RecordNotFound) {
      Individual.find(@id)
    }
  end

private

  # Create an invidual.  Pass in options to override attributes from their defaults.
  def create_individual(options = {})
    post :create, :individual => { :login => 'quired', :email => 'quire@example.com',
      :first_name => 'Walter', :last_name => 'Lunt', :enabled => true,
      :password => 'quired', :password_confirmation => 'quired' }.merge(options)
  end
end
