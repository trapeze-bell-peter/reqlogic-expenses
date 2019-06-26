class AddUserToExpenseClaim < ActiveRecord::Migration[5.2]
  def change
    add_reference :expense_claims, :user, foreign_key: true
  end
end
