Rails.application.routes.draw do
  resources :expense_claims

  root 'expense_claim#index'
end
