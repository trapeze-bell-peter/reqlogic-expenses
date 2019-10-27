# frozen_string_literal: true

# Used to generate key fields for a single row (an Expense Entry) in the Expense Claim HTML page.
class ExpenseEntryPresenter < StimulusFormPresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry)
    super(view, expense_entry)
  end

  alias expense_entry model
  alias expense_entry_form form

  def self.actions_for_claim_table
    'recalcTotalClaim->expense-claim#recalcTotalClaim resequence->expense-claim#reSequenceExpenseEntryForms'
  end

  def background
     expense_entry.receipt.attached? || expense_entry.email_receipt ? 'alert-success' : nil
  end

  # @return [String] action definitions for use by Stimulus.js on the expense-entry div
  def actions_for_expense_entry_div
    'dragstart->expense-entry#dragstart dragenter->expense-entry#dragenter dragover->expense-entry#dragover' \
      ' drop->expense-entry#drop'
  end

  def row_id
    "expense-entry-#{expense_entry.persisted? ? expense_entry.id : 'empty-row'}"
  end

  # Specifies the HTML fields to be used by the expense entry form form
  def form_hash
    { data: { target: 'expense-claim.expenseEntryForm',
              expense_entry_changed: '0',
              action: 'ajax:complete->expense-claim#ajaxComplete '\
                      'ajax:success->expense-entry#ajaxSuccessThereforeResetErrors' } }
  end

  # Generates the hidden field containing the expense claim id.  Used by the RoR backend to associate with the correct
  # expense claim.
  # @return [String]
  def expense_claim_id
    expense_entry_form.hidden_field :expense_claim_id
  end

  # Generates the hidden field in which we save sequence number.  This field is updated by the expenseClaim Stimulus.js
  # controller.
  # @return [String]
  def sequence
    expense_entry_form.text_field :sequence, class: 'form-control', disabled: true,
                                             data: { target: 'expense-claim.sequenceField' }
  end

  # Renders a selector for the different categories
  def categories
    expense_entry_form.select :category,
                              view.options_for_select(options_list, expense_entry.category),
                              { include_blank: true },
                              field_args(:category, data: { action: 'change->expense-entry#categoryChange' })
  end

  # Generate form field for description entry.
  def description
    form_field :description, :text_field, class: 'form-control', data: { target: 'expense-entry.description' }
  end

  # Helper method to generate the HTML for drop down of matching CC events.  Works closely with the HAML partial.
  # If suitable matches exist, then it yields back to the HAML to produce the HTML.
  def matching_cc_dropdown
    matching_cc_list = expense_entry.barclay_card_row_datum&.prioritised_match_list
    yield matching_cc_list unless matching_cc_list.blank?
  end

  # Helper method to create the HTML for the VAT select dropdown.
  def vat
    expense_entry_form.select :vat, %w[0 20], {},
                              field_args(:vat, placeholder: 'VAT', data: { target: 'expense-entry.vat' })
  end

  def qty
    form_field :qty, :number_field, data: { action: 'change->expense-entry#recalcClaim', target: 'expense-entry.qty' }
  end

  def unit_cost
    form_field :unit_cost, :number_field, min: '0.00', step: '0.01',
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
                   method: :delete, remote: true,
                   data: { action: 'click->expense-claim#deleteExpenseEntry', toggle: 'tooltip', placement: 'top' },
                   title: 'Delete row',
                   &method(:delete_icon))
    else
      view.link_to('_', href: '#', data: { action: 'click->expense-claim#deleteExpenseEntry' }, &method(:delete_icon))
    end
  end

  # Helper to generate the insert button for each expense entry.
  def insert_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-claim#insertExpenseEntry', toggle: 'tooltip', placement: 'top' },
                 title: 'Insert empty row') do
      view.tag.i class: 'fas fa-plus-square fa-2x expenses-action-icon'
    end
  end

  # Helper to generate the copy button for each expense entry.
  def copy_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-claim#copyExpenseEntry', toggle: 'tooltip', placement: 'top' },
                 title: 'Copy row to bottom') do
      view.tag.i class: 'fas fa-copy fa-2x expenses-action-icon'
    end
  end

  # Generates, based on the field name, the default hash that the form field would use.
  #
  # @api private
  # @param [String] field_name
  # @return [Hash]
  def default_field_hash(field_name)
    { class: form_field_class(field_name.to_sym),
      placeholder: field_name.capitalize,
      data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' } }
  end

  def receipt_image
    if expense_entry.receipt.attached?
      view.image_tag expense_entry.receipt, class: "img-fluid", hidden: true, data: { target: 'expense-entry.receiptImage' }
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