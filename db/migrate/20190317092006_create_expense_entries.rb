class CreateExpenseEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :expense_entries do |t|
      t.belongs_to :expense_claim

      t.date :date
      t.integer :sequence
      t.string :category
      t.string :description
      t.string :project
      t.integer :vat
      t.integer :qty
      t.monetize :unit_cost

      t.timestamps
      t.timestamps
    end
  end
end
