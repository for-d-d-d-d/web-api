Rails.application.routes.draw do
  get '/percentage_done', to: 'job#percentage_done'

  root 'gorae#entering'

  match "/:controller(/:action(/:id))", :via => [:post, :get]
end
