
# Factory class to generate ExpenseClaim record and associated ExpenseEntry records based on BarclayCard XLS file.
class BarclayCardImporter
  # Static method that is given a file object for a BarclayCard csv report, and imports it into the database.
  def self.run(file, user)
    worksheet = Spreadsheet.open(file.path).worksheet(0)
    expense_claim = nil

    ExpenseClaim.transaction do
      worksheet.each_with_index do |row, row_index|
        if row_index.zero?
          expense_claim = BarclayCardImporter.create_with_description_from_xlsx_import(row, user)
        elsif row_index >= 2
          BarclayCardImporter.create_from_xlsx_row(expense_claim, row)
        end
      end
      BarclayCardImporter.resequence_xlsx_import(expense_claim)
    end

    expense_claim
  end

  # Create a new expense expense_claim based on the imported Barclay Card.
  # @param [CSV::CsvRow] top_row
  # @return [ExpenseClaim]
  def self.create_with_description_from_xlsx_import(top_row, user)
    ExpenseClaim.create!(description: "Barclay card expenses from #{top_row[2]} to #{top_row[3]}", user: user)
  end

  # The Barclay card report provides the data in the wrong sequence.  This resequences by date.
  def self.resequence_xlsx_import(expense_claim)
    expense_claim.expense_entries.order(id: :desc).each_with_index do |expense_entry, index|
      expense_entry.update!(sequence: index + 1)
    end
  end

  # Factory to create an ExpenseEntry and corresponding BarclayCardRowDatum from the xlsx file
  def self.create_from_xlsx_row(expense_claim, row)
    expense_entry = ExpenseEntry.new(expense_claim: expense_claim)
    expense_entry.build_barclay_card_row_datum(BarclayCardImporter.attributes_from_xlsx(row))
    expense_entry.attributes = expense_entry.barclay_card_row_datum.attributes_for_expense_entry
    expense_entry.save!
  end

  # Take the row data from the CSV file and push into the DB
  def self.attributes_from_xlsx(row)
    { transaction_date: row[2], raw_description: row[4], mcc: row[8], mcc_description: row[9],
      currency_amount: Money.new(row[10]*100.0, row[11]), gbp_amount: row[12] }
  end
end