# frozen_string_literal: true

# Used to generate key fields for a single row (an Expense Entry) in the Expense Claim HTML page.
class ExpenseEntryForPrintPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry)
    super(view, expense_entry)
  end

  alias expense_entry model

  delegate :sequence, :category, :description, :project, :qty, to: :model

  def date
    expense_entry.date.strftime("%d/%m/%Y")
  end

  def vat
    "#{expense_entry.vat}%"
  end

  def unit_cost
    expense_entry.unit_cost.format
  end

  def total_cost
    expense_entry.total_cost.format
  end
end