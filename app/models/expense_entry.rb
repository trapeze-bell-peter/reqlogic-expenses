# frozen_string_literal: true

class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim
  has_one :barclay_card_row_datum

  monetize :unit_cost_pence

  attribute :vat, :integer, default: 20
  attribute :qty, :integer, default: 1
  attribute :project, :string, default: 'EXPENSE'

  validates :date, presence: true
  validates :vat, inclusion: [0, 20]
  validates :project, presence: true
  validates :description, presence: true

  # Factory to create an ExpenseEntry and corresponding BarclayCardRowDatum from the xlsx file
  def self.create_from_xlsx_row(expense_claim, row)
    expense_entry = ExpenseEntry.new(expense_claim: expense_claim)
    expense_entry.build_barclay_card_row_datum(BarclayCardRowDatum.attributes_from_xlsx(row))
    expense_entry.attributes = expense_entry.barclay_card_row_datum.attributes_for_expense_entry
    expense_entry.save!
  end

  # Virtual attribute to determine overall cost of an expense entry
  # @return [Money]
  def total_cost
    self.qty * self.unit_cost
  end
end
