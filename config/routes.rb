Rails.application.routes.draw do
  resources :categories

  resources :expense_claims do
    get 'export_excel', on: :member
    post 'barclay_csv_import', on: :collection
  end

  # If we create a new receipt, then this needs attaching to an expense entry, hence the nested routing.  However,
  # for updates and destroys, we only need the receipt id.
  resources :expense_entries do
    resources :email_receipts, only: :create
    resources :file_receipts, only: :create
  end
  resources :email_receipts, only: [:update, :destroy]
  resources :file_receipts, only: [:update, :destroy]

  mount ActionCable.server => '/cable'

  # Enable the sidekiq console.
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root to: 'home#index'
end
