# frozen_string_literal: true

class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim

  monetize :unit_cost_pence

  attribute :vat, :integer, default: 20
  attribute :qty, :integer, default: 1
  attribute :project, :string, default: 'EXPENSE'

  validates :vat, inclusion: [0, 20]
  validates :project, presence: true
end
