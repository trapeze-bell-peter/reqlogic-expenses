Rails.application.routes.draw do
  devise_for :users

  resources :categories
  
  resources :expense_claims do
    get 'export_excel', on: :member
    post 'barclay_csv_import', on: :collection
  end

  resources :expense_entries do
    delete 'destroy_receipt', on: :member
  end

  root 'expense_claims#index'

  # Enable the sidekiq console.
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
