# frozen_string_literal: true

# Concern that provides the functionality to write the data to the Excel spreadsheet
module ExpenseExcelExport
  include ActiveSupport::Concern

  # Generates a suggested filename based on expenses sheet data and description
  # @return [String]
  def suggested_filename
    "#{self.claim_date.strftime('%y-%m-%d')}-#{self.description.parameterize(separator: '_')}.xlsx"
  end

  # Generates the actual spreadsheet
  # @return [RubyXL::Worksheet]
  def export_excel
    @workbook = RubyXL::Workbook.new
    @expense_sheet = @workbook[0]
    @expense_sheet.sheet_name = 'Expense'

    generate_header_row
    insert_expense_entries

    @workbook
  end

  # Column names required by Reqlogic import tool
  HEADER_COLS =
    <<~HEADER
      QTY, Internal  ItemId, Description, Unit, Price, Type, Date, Project, Task, USER01, USER02, USER05, USER06,
      USER11, USER12, USER13, USER14, Dim1, Dim2, Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, Dim9, Dim10, GL Account, GL Sub,
      Currency, General Notes, Voucher Notes
    HEADER
    .split(', ').map(&:strip).freeze

  # writes out the header row based on the HEADER_COLS constant.
  # @return [Void]
  def generate_header_row
    HEADER_COLS.each_with_index do |heading, column|
      @expense_sheet.add_cell(0, column, heading, nil, :right)
    end
  end

  # Mapping between VAT rate and the values required by Reqlogic
  VAT_MAPPING = { 0 => 'E1', 20 => 'E3' }.freeze

  # Generate the rows with the details of the expense entry.
  # @return [Void]
  # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
  def insert_expense_entries
    self.expense_entries.order(:sequence).each.with_index do |expense_entry, index|
      row = index + 1
      @expense_sheet.add_cell(row, 0, expense_entry.qty)
      @expense_sheet.add_cell(row, 1, expense_entry.category)
      @expense_sheet.add_cell(row, 2, expense_entry.description)
      @expense_sheet.add_cell(row, 3, 'EACH')
      @expense_sheet.add_cell(row, 4, expense_entry.unit_cost.to_f)
      # ToDo: challenge why this is always supposed to be E1.  Surely a bug in the ReqLogic import.
      @expense_sheet.add_cell(row, 5, 'E2')
      self.write_date(row, expense_entry)
      @expense_sheet.add_cell(row, 7, expense_entry.project)
    end
  end
  # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

  # Adds the {expense_entry}'s date to the row and formats it correctly.
  #
  # @param [Object] row
  # @param [Object] expense_entry
  # @return [Void]
  def write_date(row, expense_entry)
    cell = @expense_sheet.add_cell(row, 6)
    cell.raw_value = expense_entry.date
  end
end