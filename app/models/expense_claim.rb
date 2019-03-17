class ExpenseClaim < ApplicationRecord
  has_many :expense_entries, dependent: :destroy

  accepts_nested_attributes_for :expense_entries
end
