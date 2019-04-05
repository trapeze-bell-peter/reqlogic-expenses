# frozen_string_literal: true

class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim

  monetize :unit_cost_pence

  attribute :vat, :integer, default: 20
  attribute :qty, :integer, default: 1
  attribute :project, :string, default: 'EXPENSE'

  validates :date, presence: true
  validates :vat, inclusion: [0, 20]
  validates :project, presence: true
  validates :description, presence: true

  # Virtual attribute to determine overall cost of an expense entry
  # @return [Money]
  def total_cost
    self.qty * self.unit_cost
  end
end
