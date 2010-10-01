ActionController::Routing::Routes.draw do |map|
  map.resources :docs, :member => 'changeset'
end