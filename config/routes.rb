Planigle::Application.routes.draw do
  post '/stories/import', :to => 'stories#import', :as => 'import'
  get '/stories/export', :to => 'stories#export', :as => 'export'
  post '/stories/split/:id', :to => 'stories#split', :as => 'split'
  get '/stories/epics', :to => 'stories#epics', :as => 'epics'
  get '/stories/num_pages', :to => 'stories#num_pages', :as => 'num_story_pages'
  get '/audits/num_pages', :to => 'audits#num_pages', :as => 'num_audit_pages'

  resources :audits
  
  resources :stories do
    resources :tasks
  end

  resources :iterations do
    resources :stories
  end

  resources :releases

  resources :companies

  resources :projects do
    resources :teams
  end

  resources :individuals
  resources :surveys
  resources :story_attributes

  resource :session
  resource :system
  resources :errors

  get '/summarize', :to => 'systems#summarize', :as => 'summarize'
  get '/report_iteration_totals', :to => 'systems#report_iteration_totals', :as => 'report_iteration_totals'
  get '/report_release_totals', :to => 'systems#report_release_totals', :as => 'report_release_totals'
  get '/report_team_totals', :to => 'systems#report_team_totals', :as => 'report_team_totals'
  get '/report_upcoming_iterations', :to => 'systems#report_upcoming_iterations', :as => 'report_upcoming_iterations'
  get '/report_iteration_metrics', :to => 'systems#report_iteration_metrics', :as => 'report_iteration_metrics'
  post '/session/reset_password', :to => 'sessions#reset_password', :as => 'reset_password'
  get '/activate/:activation_code', :to => 'individuals#activate', :as => 'activate'
  get '/logout', :to => 'sessions#logout', :as => 'logout'

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # connect '', :controller => "welcome"

  #connect '', :controller => 'stories', :action => 'index'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # connect ':controller/:action/:id.:format'
  # connect ':controller/:action/:id'
end
