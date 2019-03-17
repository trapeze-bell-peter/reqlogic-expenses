class CreateExpenseClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :expense_claims do |t|
      t.string :description
      t.date :claim_date

      t.timestamps
    end
  end
end
