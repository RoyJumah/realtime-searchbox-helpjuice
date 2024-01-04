Rails.application.routes.draw do
  resources :search_queries, only: [:index, :create]

  post '/search', to: 'search_queries#create'
  get 'get_similar_queries', to: 'search_queries#get_similar_queries'

  root 'search_queries#index'
end