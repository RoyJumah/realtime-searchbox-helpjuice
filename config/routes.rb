Rails.application.routes.draw do
  resources :search_queries, only: [:index, :create]

  post '/search', to: 'search_queries#create'
  get 'get_similar_queries', to: 'search_queries#get_similar_queries'
  get 'search_queries/history', to: 'search_queries#get_search_history'

  root 'search_queries#index'
end