class CreateBarclayCardRowData < ActiveRecord::Migration[5.2]
  def change
    create_table :barclay_card_row_data do |t|
      t.date :posting_date, null: false
      t.string :raw_description, null: false
      t.string :city
      t.string :mcc, null: false
      t.string :mcc_description, null: false

      t.monetize :currency_amount
      t.monetize :gbp_amount

      t.belongs_to :expense_entry, index: true

      t.timestamps
    end
  end
end
