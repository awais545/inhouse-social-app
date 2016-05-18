Rails.application.routes.draw do
  get 'welcome/index'

  devise_for :users

  get 'welcome/index'
  root 'welcome#index'
end
