# frozen_string_literal: true

require 'spreadsheet'

class ExpenseClaim < ApplicationRecord
  include ExpenseExcelExport

  belongs_to :user, dependent: :destroy

  has_many :expense_entries, dependent: :destroy

  attribute :claim_date, :date, default: -> { Time.zone.today }

  validates :claim_date, presence: true

  accepts_nested_attributes_for :expense_entries

  # Provides a static method to add sequence numbers to an existing database.
  # @return [Void]
  def self.resequence
    ExpenseClaim.all.find_each do |expense_claim|
      offset = expense_claim.expense_entries.maximum(:sequence) || 1

      expense_claim.expense_entries.where(sequence: nil).each_with_index do |expense_entry, i|
        expense_entry.update!(sequence: i + offset)
      end
    end
  end

  def total
    Money.new(self.expense_entries.sum('unit_cost_pence * qty'))
  end
end
