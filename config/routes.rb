Rails.application.routes.draw do
  resources :categories
  resources :expense_claims
  resources :expense_entries

  root 'expense_claims#index'
end
