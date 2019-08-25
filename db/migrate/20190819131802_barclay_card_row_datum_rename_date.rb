class BarclayCardRowDatumRenameDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :barclay_card_row_data, :posting_date, :transaction_date
  end
end
