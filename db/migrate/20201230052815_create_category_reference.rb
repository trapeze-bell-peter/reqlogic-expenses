class CreateCategoryReference < ActiveRecord::Migration[6.1]
  def change
    rename_column :expense_entries, :category, :category_string
    add_reference :expense_entries, :category, index: true
  end
end
