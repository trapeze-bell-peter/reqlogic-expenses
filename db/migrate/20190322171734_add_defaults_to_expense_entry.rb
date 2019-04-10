class AddDefaultsToExpenseEntry < ActiveRecord::Migration[5.2]
  def change
    change_column :expense_entries, :vat, :integer, default: 20, null: false
    change_column :expense_entries, :qty, :integer, default: 1, null: false
  end
end
