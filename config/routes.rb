Rails.application.routes.draw do
  devise_for :users
  resources :categories
  
  resources :expense_claims do
    get 'export_excel', on: :member
    post 'barclay_csv_import', on: :collection
  end

  resources :expense_entries

  root 'expense_claims#index'
end
