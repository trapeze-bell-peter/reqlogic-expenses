# frozen_string_literal: true

require 'spreadsheet'

class ExpenseClaim < ApplicationRecord
  include ExpenseExcelExport

  belongs_to :user

  has_many :expense_entries, dependent: :destroy

  attribute :claim_date, :date, default: -> { Time.zone.today }

  validates :claim_date, presence: true

  accepts_nested_attributes_for :expense_entries

  scope :sorted_claims, lambda {
    joins(:expense_entries)
      .select('expense_claims.*, MIN(expense_entries.date) AS first_date, MAX(expense_entries.date) AS last_date')
      .group('expense_claims.id')
      .order('first_date')
  }

  def from_date
    self.expense_entries.minimum(:date)
  end

  def to_date
    self.expense_entries.maximum(:date)
  end

  # Calculates the total cost of the expense claim
  # @return [Money]
  def total
    Money.new(self.expense_entries.sum('unit_cost_pence * qty'))
  end

  def expense_entries_with_receipts
    self.expense_entries.order(:sequence).to_a.keep_if do |expense_entry|
      expense_entry.receipt.attached? || expense_entry.old_email_receipt
    end
  end

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
end
