Rails.application.routes.draw do
  get 'json/song'
  post 'json/regist'
  get 'json/regist'
  
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
  :registrations => "users/registrations",
  :sessions => "users/sessions" }
  
  root 'home#entering'

  match "/:controller(/:action(/:id))", :via => [:post, :get]
  
end
