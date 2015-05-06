HileSearch::Application.routes.draw do
  root 'device_brands#index'
  get 'contact/' => 'contact#index'
  get 'bags/' => 'bag_items#index'

  # todo fix
  get '*path', controller: 'application', action: 'error_handler'
  post '*path', controller: 'application', action: 'error_handler'
end
