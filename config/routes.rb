Rails.application.routes.draw do
  devise_for :users

  resources :documents, only: [:show]
end
