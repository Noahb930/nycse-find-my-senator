Rails.application.routes.draw do
  resources :votes
  resources :bills
  resources :senators
  root 'static_pages#home'
  post '/', to: 'senators#find'
  get '/senators/:id/record', to: 'senators#votes'
end
