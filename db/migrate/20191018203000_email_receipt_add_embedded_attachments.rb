class EmailReceiptAddEmbeddedAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :email_receipts, :embedded_images, :json
  end
end
