# frozen_string_literal: true

class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim

  monetize :unit_cost_pence


end
