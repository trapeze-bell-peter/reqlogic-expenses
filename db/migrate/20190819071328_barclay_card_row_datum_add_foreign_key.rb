class BarclayCardRowDatumAddForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :barclay_card_row_data, :expense_entries
  end
end
