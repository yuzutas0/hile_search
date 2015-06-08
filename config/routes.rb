HileSearch::Application.routes.draw do
  root 'device_brands#index'

  get 'device/' => 'device_items#index'
  get 'device_items/index' => 'device_items#index'
  
  get 'bags/' => 'bag_items#index'
  get 'contact/' => 'contact#index'

  # todo fix
  get '*path', controller: 'application', action: 'error_handler'
  post '*path', controller: 'application', action: 'error_handler'
end
