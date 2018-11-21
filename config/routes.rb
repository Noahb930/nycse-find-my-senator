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
    get '/statesenate', to: 'representatives#admin_state_senate_index'
    get '/assembly', to: 'representatives#admin_state_assembly_index'
  end
  root 'static_pages#home'
  get '/show/:addr/:city/:zip', to: "static_pages#show"
  post '/', to: 'representatives#find'
  get '/representatives/:id/donations', to: 'representatives#donations'
  post '/representatives/:id/contact', to: 'representatives#mail'
  get '/partials/show' => 'representatives#show', :as => 'show_representative'
  get '/partials/votes' => 'representatives#votes', :as => 'votes_representative'
  get '/partials/donations' => 'representatives#donations', :as => 'donations_representative'
  get '/partials/contact' => 'representatives#contact', :as => 'contact_representative'
end
