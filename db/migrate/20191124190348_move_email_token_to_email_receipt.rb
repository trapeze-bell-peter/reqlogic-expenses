class MoveEmailTokenToEmailReceipt < ActiveRecord::Migration[6.0]
  def change
    remove_column :expense_entries, :email_receipt_token
    add_column :receipts, :email_receipt_token, :string
  end
end
