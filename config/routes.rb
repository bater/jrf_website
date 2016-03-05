Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  root 'static_pages#home'
  match '/about',     to: 'static_pages#about',     via: 'get'
  match '/donate',    to: 'static_pages#donate',    via: 'get'
  match '/search',    to: 'static_pages#search',    via: 'get'
  match '/thanks',    to: 'static_pages#thanks',    via: 'get'
  match '/feed',      to: 'static_pages#feed',      format: 'atom', via: 'get'
  match "/sitemap",   to: 'static_pages#sitemap',   format: 'xml',  via: 'get'

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  resources :articles, only: [:show, :index] do
    get :presses, on: :collection
    get :activities, on: :collection
    get :comments, on: :collection
    get :epapers, on: :collection
    get :books, on: :collection
  end
  resources :keywords, only: [:show]
  # resources :catalogs
  # resources :categories
  # resources :kinds, only: [:show, :index]
  resources :magazines
  resources :magazine_articles
  resources :columns
  resources :epapers, only: [:show, :index]
  get "/admin" => redirect("/users/sign_in")
  namespace :admin do
    # root 'admins#index',             via: 'get', as: 'admin'
    resources :articles, except: [:show]
    resources :users, only: [:index, :update]
    resources :catalogs, except: [:show] do
      put :sort, on: :collection
    end
    resources :categories, except: [:show] do
      put :sort, on: :collection
    end
    resources :keywords, except: [:show] do
      get :order, on: :collection
      get :show_order, on: :collection
      put :sort,  on: :collection
      put :show_sort,  on: :collection
      resources :faqs, only: [:index]
    end
    match 'faqs/sort',  to: 'faqs#sort',  via: 'put'
  end

  namespace :api, defaults: { format: 'json' } do
    resources :articles, only: [:show, :index]
    resources :keywords, only: [:show, :index]
    resources :catalogs, only: [:show, :index]
  end

  match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ], as: 'not_found'
  match "/422" => "errors#error422", via: [ :get, :post, :patch, :delete ]
  match "/500" => "errors#error500", via: [ :get, :post, :patch, :delete ]

  get '/api' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')
end
