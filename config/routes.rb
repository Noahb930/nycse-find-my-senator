Rails.application.routes.draw do





  scope '/admin' do
    resources :votes, except: [:index, :edit, :show]
    resources :bills
    resources :donations, only: [:create, :destroy]
    resources :lobbyists
    get '/bills/', to: 'bills#admin_index'
    get '/bills/:id', to: 'bills#admin_show'
    resources :senators, except: [:index, :show, :find, :destroy, :new, :create, :destroy_all]
    get '/senators/', to: 'senators#admin_index'
    get '/senators/:id', to: 'senators#admin_show'
    get '/senators/:id/votes', to: 'senators#admin_votes'
    get '/senators/:id/donations', to: 'senators#admin_donations'
  end
  resources :senators, only: [:index, :show]
  root 'static_pages#home'
  post '/', to: 'senators#find'
  get '/senators/:id/votes', to: 'senators#votes'
  get '/senators/:id/donations', to: 'senators#donations'
end
