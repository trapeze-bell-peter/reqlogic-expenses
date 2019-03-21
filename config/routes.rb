Rails.application.routes.draw do
  resources :categories
  resources :expense_claims

  root 'expense_claims#index'
end
