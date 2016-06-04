Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
  :registrations => "users/registrations",
  :sessions => "users/sessions" }

  root 'home#entering'

  match "/:controller(/:action(/:id))", :via => [:post, :get]
  
end
