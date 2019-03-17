Rails.application.routes.draw do
  resources :expense_claims

  root 'expense_claims#index'
end
