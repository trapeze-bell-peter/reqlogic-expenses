# frozen_string_literal: true

require 'spreadsheet'

class ExpenseClaim < ApplicationRecord
  include ExpenseExcelExport

  has_many :expense_entries, dependent: :destroy

  attribute :claim_date, :date, default: -> { Time.zone.today }

  validates :claim_date, presence: true

  accepts_nested_attributes_for :expense_entries

  # Static method that is given a file object for a BarclayCard csv report, and imports it into the database.
  def self.barclay_xlsx_import(file)
    worksheet = Spreadsheet.open(file.path).worksheet(0)
    expense_claim = nil

    ExpenseClaim.transaction do
      worksheet.each_with_index do |row, row_index|
        if row_index.zero?
          expense_claim = ExpenseClaim.create_with_description_from_xlsx_import(row)
        elsif row_index >= 2
          ExpenseEntry.create_from_xlsx_row(expense_claim, row)
        end
      end
      expense_claim.resequence_xlsx_import
    end

    expense_claim
  end

  # Create a new expense claim based on the imported Barclay Card.
  # @param [CSV::CsvRow] top_row
  # @return [ExpenseClaim]
  def self.create_with_description_from_xlsx_import(top_row)
    ExpenseClaim.create!(description: "Barclay card expenses from #{top_row[2]} to #{top_row[3]}")
  end

  # The Barclay card report provides the data in the wrong sequence.  This resequences by date.
  def resequence_xlsx_import
    self.expense_entries.order(:date, :id).each_with_index do |expense_claim, index|
      expense_claim.update!(sequence: index + 1)
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

  def total
    Money.new(self.expense_entries.sum('unit_cost_pence * qty'))
  end
end
