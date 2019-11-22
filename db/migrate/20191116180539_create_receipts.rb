class CreateReceipts < ActiveRecord::Migration[6.0]
  def change
    create_table :receipts do |t|
      t.string :type
      t.references :expense_entry, null:false, index: true

      # Fields for email receipt
      t.string :title
      t.json :embedded_images
      t.text :email_body

      t.timestamps
    end

    FileReceipt.move_receipt_images
    EmailReceipt.copy_from_old_email_receipt
  end
end
