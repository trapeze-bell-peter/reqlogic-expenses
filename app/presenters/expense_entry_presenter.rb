# frozen_string_literal: true

# Used to generate key fields for a single row (an Expense Entry) in the Expense Claim HTML page.
class ExpenseEntryPresenter < BasePresenter
  include FormField

  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry)
    super(view)
    @expense_entry = expense_entry
  end

  attr_reader :expense_entry

  def self.actions_for_claim_table
    'recalcTotalClaim->expense-claim#recalcTotalClaim'
  end

  # @return [String] action definitions for use by Stimulus.js on the expense-entry div
  def actions_for_expense_entry_div
    'dragstart->expense-entry#dragstart dragenter->expense-entry#dragenter dragover->expense-entry#dragover' +
      ' drop->expense-entry#drop'
  end

  def row_id
    "expense-entry-#{expense_entry.persisted? ? expense_entry.id : 'empty-row'}"
  end

  FORM_ACTIONS = 'ajax:complete->expense-claim#ajaxComplete ajax:success->expense-entry#ajaxSuccessThereforeResetErrors'

  # Generates the form used in a row.
  def form
    view.form_with(model: expense_entry,
                   class: 'form',
                   data: { target: 'expense-claim.form',
                           expense_entry_changed: expense_entry.persisted? ? '0' : '1',
                           action: FORM_ACTIONS }) do |expense_entry_form|
      @expense_entry_form = expense_entry_form
      yield(expense_entry_form)
    end
  end

  attr_reader :expense_entry_form

  def expense_claim_id
    expense_entry_form.hidden_field :expense_claim_id
  end

  def sequence
    expense_entry_form.hidden_field :sequence, data: { target: 'expense-claim.sequenceField' }
  end

  # Renders a date field for the expense entry form
  def date
    form_field :date_field
  end

  # Renders a selector for the different categories
  def categories
    expense_entry_form.select :category,
                              view.options_for_select(options_list, expense_entry.category),
                              {},
                              field_args(:category, data: { action: 'change->expense-entry#categoryChange' })
  end

  # Renders a text field for the description
  def description
    form_field :text_field
  end

  # Renders a text field for the description
  # @todo replace with a lookup based on JET data
  def project
    form_field :text_field
  end

  def vat
    expense_entry_form.select :vat, %w[0 20], {},
                              field_args(:vat, placeholder: 'VAT', data: { target: 'expense-entry.vat' })
  end

  def qty
    form_field :number_field, data: { action: 'change->expense-entry#recalcClaim', target: 'expense-entry.qty' }
  end

  def unit_cost
    form_field :number_field, min: '0.00', step: '0.01',
                              data: { action: 'change->expense-entry#recalcClaim',
                                      target: 'expense-entry.unitCost' }
  end

  def total_cost
    view.text_field_tag :total_cost, expense_entry.total_cost,
                        disabled: true,
                        class: 'form-control', data: { target: 'expense-entry.totalCost expense-claim.totalCost' }
  end

  def delete_button
    if expense_entry.persisted?
      view.link_to(view.expense_entry_path(expense_entry),
                   method: :delete, remote: true, data: { action: 'ajax:success->expense-claim#deleteExpenseEntry' },
                   &method(:delete_icon))
    else
      view.link_to('_', href: '#', data: { action: 'click->expense-claim#deleteExpenseEntry' }, &method(:delete_icon))
    end
  end

  def insert_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-claim#insertExpenseEntry' }) do
      view.tag.i class: 'fas fa-plus-square fa-2x expenses-action-icon'
    end
  end

  def copy_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-claim#copyExpenseEntry' }) do
      view.tag.i class: 'fas fa-copy fa-2x expenses-action-icon'
    end
  end

  private

  def delete_icon
    view.tag.i class: 'fas fa-trash fa-2x expenses-action-icon'
  end

  def options_list
    Category.order(:name).each_with_object([]) do |category, options_array|
      options_array << [category.name, category.name,
                        {}, data: { vat: category.vat, unitCost: category.unit_cost.to_s }]
    end
  end
end