ActionController::Routing::Routes.draw do |map|
  map.sort_stories '/stories/sort_stories', :controller => 'stories', :action => 'sort_stories'
  map.sort_stories_format '/stories/sort_stories.:format', :controller => 'stories', :action => 'sort_stories'
  map.resources :iterations
  map.resources :individuals
  map.resources :stories
  map.resource :session
  map.activate '/activate/:activation_code', :controller => 'individuals', :action => 'activate'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  #map.connect '', :controller => 'stories', :action => 'index'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.root :controller => 'iterations'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
