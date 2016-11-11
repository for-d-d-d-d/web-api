Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'json/song'
  post 'json/regist'
  get 'json/regist'
  
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
  :registrations => "users/registrations",
  :sessions => "users/sessions" }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy'     # , :as => :destroy_user_session
  end
  
  #root 'home#entering'
  root 'admin2#crawler_manager'
  get "/we/admin2(/:action(/:id))" => "admin2#:action"
  post "/we/admin2(/:action(/:id))" => "admin2#:action"
  match "/:controller(/:action(/:id))", :via => [:post, :get]
  
end
