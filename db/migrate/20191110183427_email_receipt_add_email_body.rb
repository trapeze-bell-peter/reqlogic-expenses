class EmailReceiptAddEmailBody < ActiveRecord::Migration[6.0]
  def change
    EmailReceipt.delete_all

    add_column :email_receipts, :email_body, :text, null: false
  end
end
