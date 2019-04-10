Rails.application.routes.draw do
  resources :categories
  resources :expense_claims do
    member do
      get 'export_excel'
    end
  end
  resources :expense_entries

  root 'expense_claims#index'
end
