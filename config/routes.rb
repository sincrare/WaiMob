Rails.application.routes.draw do
  root to: 'rooms#index'
  devise_for :users

  resources :rooms, only: %i[show]
end
