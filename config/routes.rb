Rails.application.routes.draw do





  scope '/admin' do
    resources :votes, except: [:index, :edit, :show]
    resources :bills
    resources :donations, only: [:create, :destroy]
    resources :lobbyists
    get '/bills/', to: 'bills#admin_index'
    get '/bills/:id', to: 'bills#admin_show'
    resources :representatives, except: [:index, :show, :find, :destroy, :new, :create, :destroy_all, :contact]
    get '/representatives/', to: 'representatives#admin_index'
    get '/representatives/:id', to: 'representatives#admin_show'
    get '/representatives/:id/votes', to: 'representatives#admin_votes'
    get '/representatives/:id/donations', to: 'representatives#admin_donations'
  end
  resources :representatives, only: [:index, :show]
  root 'static_pages#home'
  get '/show/:addr/:city/:zip', to: "static_pages#show"
  post '/', to: 'representatives#find'
  get '/representatives/:id/votes', to: 'representatives#votes'
  get '/representatives/:id/donations', to: 'representatives#donations'
  get '/representatives/:id/contact', to: 'representatives#contact'
  post '/representatives/:id/contact', to: 'representatives#mail'
end
