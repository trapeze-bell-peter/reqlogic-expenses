class RenameEmailReceiptToOldEmailReceipt < ActiveRecord::Migration[6.0]
  def change
    rename_table :email_receipts, :old_email_receipts
  end
end
