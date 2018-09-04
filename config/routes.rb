Rails.application.routes.draw do



  scope '/admin' do
    resources :votes, except: [:index, :edit, :show]
    resources :bills, except: [:index, :show]
    get '/bills/', to: 'bills#admin_index'
    get '/bills/:id', to: 'bills#admin_show'
    resources :senators, except: [:index, :show, :find, :votes]
    get '/senators/', to: 'senators#admin_index'
    get '/senators/:id', to: 'senators#admin_show'
    get '/senators/:id/votes', to: 'senators#admin_votes'
  end
  resources :senators, only: [:index, :show, :votes]
  root 'static_pages#home'
  post '/', to: 'senators#find'
  get '/senators/:id/votes', to: 'senators#votes'
end
