class CreateEmailReceipt < ActiveRecord::Migration[6.0]
  def change
    create_table :email_receipts do |t|
      t.string :title
      t.references :expense_entry, null: false
    end
  end
end
