Errbit::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # Hoptoad Notifier Routes
  match '/notifier_api/v2/notices' => 'notices#create', via: [:get, :post]
  get '/locate/:id' => 'notices#locate', :as => :locate
  post '/deploys.txt' => 'deploys#create'

  resources :notices,   :only => [:show]
  resources :deploys,   :only => [:show]
  resources :exception_filters
  resources :priority_filters
  resources :users do
    member do
      delete :unlink_github
    end
  end
  resources :problems,      :only => [:index] do
    collection do
      post :destroy_several
      post :resolve_several
      post :unresolve_several
      post :merge_several
      post :unmerge_several
      get :search
    end
  end

  resources :apps do
    resources :problems do
      resources :notices
      resources :comments, :only => [:create, :destroy]

      collection do
        post :destroy_all
      end

      member do
        put :resolve
        put :unresolve
        post :create_issue
        delete :unlink_issue
      end
    end
    resources :deploys, :only => [:index]
    resources :watchers, :only => [:destroy]
    put 'watchers/:id/assign', to: 'watchers#assign', as: 'watcher_assign'
    member do
      post :regenerate_api_key
    end
  end

  namespace :api do
    namespace :v1 do
      resources :problems, :only => [:index], :defaults => { :format => 'json' }
      get 'problems/week', defaults: { format: 'json' }
      resources :notices,  :only => [:index], :defaults => { :format => 'json' }
      resources :stats, :only => [], :defaults => { :format => 'json' } do
        collection do
          get :app
        end
      end
    end
  end

  root :to => 'apps#index'

end

