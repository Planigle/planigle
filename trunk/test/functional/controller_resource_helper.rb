module ControllerResourceHelper
  # Test getting a listing of resources without credentials.
  def test_index_unauthorized
    get :index
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting a listing of resources.
  def test_index_success
    login_as(individuals(:quentin))
    get :index
    assert_response :success
    assert_template 'index'
  end

  # Test getting the form to create a new resource without credentials.
  def test_new_unauthorized
    get :new
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting the form to create a new resource.
  def test_new_success
    login_as(individuals(:quentin))
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(resource_symbol)
  end

  # Test creating a new resource without credentials.
  def test_create_unauthorized
    num = resource_count
    post :create, create_success_parameters
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_equal num, resource_count
    assert_change_failed
  end

  # Test successfully creating a new resource.
  def test_create_success
    login_as(individuals(:quentin))
    num = resource_count
    post :create, create_success_parameters
    assert_redirected_to :action => 'index'
    assert_equal num + 1, resource_count
    assert_create_succeeded
  end

  # Test creating a new resource unsuccessfully.
  def test_create_failure
    login_as(individuals(:quentin))
    num = resource_count
    post :create, create_failure_parameters
    assert_response :success
    assert_template 'new'
    assert_equal num, resource_count
    assert_change_failed
  end

  # Test showing an resource without credentials.
  def test_show_unauthorized
    get :show, :id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully showing a resource.
  def test_show_success
    login_as(individuals(:quentin))
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(resource_symbol)
    assert assigns(resource_symbol).valid?
  end
    
  # Test unsuccessfully showing a resource.
  def test_show_not_found
    login_as(individuals(:quentin))
    get :show, :id => 999
    assert_redirected_to :action => :index
  end

  # Test getting the form to edit an resource without credentials.
  def test_edit_unauthorized
    get :edit, :id => 1
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end
    
  # Test successfully getting the form to edit an resource.
  def test_edit_success
    login_as(individuals(:quentin))
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(resource_symbol)
    assert assigns(resource_symbol).valid?
  end
    
  # Test unsuccessfully getting the form to edit an resource.
  def test_edit_not_found
    login_as(individuals(:quentin))
    get :edit, :id => 999
    assert_redirected_to :action => :index
  end

  # Test updating an resource without credentials.
  def test_update_unauthorized
    put :update, {:id => 1}, update_success_parameters
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_change_failed
  end

  # Test succcessfully updating an resource.
  def test_update_success
    login_as(individuals(:quentin))
    put :update, :id => 1, resource_symbol => (update_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_redirected_to :action => :index
    assert_update_succeeded
  end

  # Test updating an resource where the update fails.
  def test_update_failure
    login_as(individuals(:quentin))
    put :update, :id => 1, resource_symbol => (update_failure_parameters[resource_symbol]) # hack to get around compiler issue
    assert_response :success
    assert_template 'edit'
    assert_change_failed
  end

  # Test unsucccessfully (not found) updating an resource.
  def test_update_not_found
    login_as(individuals(:quentin))
    put :update, :id => 999, resource_symbol => (update_success_parameters[resource_symbol]) # hack to get around compiler issue
    assert_redirected_to :action => :index
  end

  # Test deleting an resource without credentials.
  def test_destroy_unauthorized
    delete :destroy, :id => 2
    assert_redirected_to :controller => 'sessions', :action => 'new'
    assert_delete_failed
  end
    
  # Test successfully deleting a resource.
  def test_destroy_success
    login_as(individuals(:quentin))
    delete :destroy, :id => 2
    assert_redirected_to :action => :index
    assert_delete_succeeded
  end
    
  # Test unsuccessfully (not found) deleting a resource.
  def test_destroy_not_found
    login_as(individuals(:quentin))
    delete :destroy, :id => 999
    assert_redirected_to :action => :index
  end
    
  # Test successfully deleting a resource while returning html for the remaining resources.
  def test_destroy_partial
    login_as(individuals(:quentin))
    xhr :delete, :destroy, :id => 2
    assert_response :success
    assert_template partial_resource
    assert_delete_succeeded
  end
    
  # Test unsuccessfully deleting a resource while returning html for the remaining resources.
  def test_destroy_partial_not_found
    login_as(individuals(:quentin))
    xhr :delete, :destroy, :id => 999
    assert_response 404
  end
end