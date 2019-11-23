class DropOldEmailReceiptTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :old_email_receipts
  end
end
