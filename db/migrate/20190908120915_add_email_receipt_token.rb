class AddEmailReceiptToken < ActiveRecord::Migration[6.0]
  def change
    add_column :expense_entries, :email_receipt_token, :string, index: true
  end
end
