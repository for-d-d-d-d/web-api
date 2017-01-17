Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  devise_for :users, :controllers => {omniauth_callbacks: "users/omniauth_callbacks",
  :registrations => "users/registrations",
  :sessions => "users/sessions" }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy'     # , :as => :destroy_user_session
  end
  
  # root 'home#entering'
  root 'admin2#crawler_manager'
  get "/we/admin2(/:action(/:id))" => "admin2#:action"
  post "/we/admin2(/:action(/:id))" => "admin2#:action"
  match "/:controller(/:action(/:id))", :via => [:post, :get]
  
  get "/beta(/:admin_name(/:complete_beta_user))", to: 'admin2#betaUser'
  get "/survey(/:action(/:id))", to: "admin2#:action"
  match "/we/admin2/get_ids(/:id)", to: "admin2#get_ids", :via => [:get, :post, :delete]
  
  get   "/show/dummy",  to: 'admin2#research'
  get   "/start",       to: "admin2#login"
  post  "/new/dummy",   to: "admin2#create_dummy_user"
  get   "/teach(/:id)", to: "admin2#info2"
  match "/ajax/:action(/:id)", to: "admin2#:action", via: [:post, :get, :delete]
  get   "/end",         to: "admin2#ending"
  
  # REST-API TRIAL
  # namespace :api do
  #   resources :my_song
    
  # end
  
  # RealTime RESTful Routing
  post '/api/user/login',         to: "api/user#login"
  get '/api/user/find_password',  to: "api/user#find_password"
  namespace :api do
      resources :mylist do
          resources :my_song
          # => (유관 조회) GET    /api/mylist/:mylist_id/my_song          api/my_song#index
          # => (신규 작성) GET    /api/mylist/:mylist_id/my_song/new      api/my_song#new
          # => (신규 생성) POST   /api/mylist/:mylist_id/my_song          api/my_song#create
          # => (지목 조회) GET    /api/mylist/:mylist_id/my_song/:id      api/my_song#show
          # => (수정 작성) GET    /api/mylist/:mylist_id/my_song/:id/edit api/my_song#edit
          # => (수정 갱신) PUT    /api/mylist/:mylist_id/my_song/:id      api/my_song#update
          # => (지목 삭제) DELETE /api/mylist/:mylist_id/my_song/:id      api/my_song#destroy
      end
      resources :interface, :blacklist_song, :user
  end
  
  get '/api/:action', to: "api/interface#:action"
  
end
