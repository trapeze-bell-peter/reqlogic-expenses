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
    expense_entry.receipt&.arrived? ? 'alert-success' : nil
  end

  # @return [Hash] the data hash for the div on the controller.  Defines the controller, the actions, the paths
  #   to be used, and the receipt size to be set in the modal
  def data_for_controller
    {
      controller: CONTROLLER,
      action: ACTIONS_FOR_EXPENSE_ENTRY_DIV
    }
    .merge(receipt_path_and_action(EmailReceipt))
    .merge(receipt_path_and_action(FileReceipt))
    .merge(receipt_size)
  end

  private

  # Most of the data that goes into the expense entries' controlling div is fixed.  Therefore, we create at startup
  # a set of constants for that element.  This includes the actions, the paths to the relevant receipt controller
  # and the action on that receipt controller.
  CONTROLLER = 'expense-entry'
  UNDERSCORED_CONTROLLER = CONTROLLER.underscore

  ACTIONS_FOR_EXPENSE_ENTRY_DIV = %w(dragstart dragenter dragover drop).map{ |e| "#{e}->#{CONTROLLER}##{e}" }.join(' ')

  UPDATE_PATH_METHOD = { EmailReceipt => :email_receipt_path, FileReceipt => :file_receipt_path }.freeze
  CREATE_PATH_METHOD = { EmailReceipt => "#{UNDERSCORED_CONTROLLER}_email_receipts_path".to_sym,
                         FileReceipt => "#{UNDERSCORED_CONTROLLER}_file_receipts_path".to_sym
                       }.freeze

  # The different receipt classes need to be referenced as underscored names for the paths.  Rather than calculate these
  # each time we store them in a class cache.
  @@underscored_class = {}

  # If the receipt exists, then generate a path to the receipt, otherwise generate a create PATH via expense_entry.
  def receipt_path_and_action(receipt_class)
    _underscored_class = underscored_class(receipt_class)
    action_key = "#{UNDERSCORED_CONTROLLER}_#{_underscored_class}_action"
    method_key = "#{UNDERSCORED_CONTROLLER}_#{_underscored_class}_method"

    if expense_entry.receipt.class == receipt_class
      { action_key => _update_path_for_receipt(receipt_class), method_key => 'PUT' }
    else
      { action_key => _create_path_for_receipt(receipt_class), method_key => 'POST' }
    end
  end

  # Generates the appropriate URL path for updating an existing receipt.  Takes account of the class of the receipt
  def _update_path_for_receipt(receipt_class)
    view.send(UPDATE_PATH_METHOD[receipt_class], expense_entry.receipt.id || 1)
  end

  def _create_path_for_receipt(receipt_class)
    view.send(CREATE_PATH_METHOD[receipt_class], expense_entry_id: (expense_entry.id || 1))
  end

  def underscored_class(receipt_class)
    @@underscored_class[receipt_class] ||= receipt_class.to_s.underscore
  end

  def receipt_size
    { "#{UNDERSCORED_CONTROLLER}_receipt_size" => expense_entry.receipt&.receipt_size }
  end

  public

  def row_id
    "expense-entry-#{expense_entry.persisted? ? expense_entry.id : 'empty-row'}"
  end

  # Specifies the HTML fields to be used by the expense entry form form
  def form_hash
    { data: { target: 'expense-claim.expenseEntryForm expense-entry.form',
              expense_entry_changed: '0',
              action: 'ajax:complete->expense-claim#ajaxComplete '\
                      'ajax:success->expense-entry#ajaxSuccessThereforeResetErrors' } }
  end

  # Generates the hidden field containing the expense claim id.  Used by the RoR backend to associate with the correct
  # expense claim.
  # @return [String]
  def expense_claim_id
    expense_entry_form.hidden_field :expense_claim_id, id: form_field_id(:expense_claim_id)
  end

  # Generates the hidden field in which we save sequence number.  This field is updated by the expenseClaim Stimulus.js
  # controller.
  # @return [String]
  def sequence
    expense_entry_form.text_field :sequence, id: form_field_id('sequence'),
                                             class: 'form-control', readonly: true,
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
    view.text_field_tag :total_cost, expense_entry.total_cost, id: form_field_id(:total_cost),
                                                               disabled: true,
                                                               class: 'form-control',
                                                               data: { target: 'expense-entry.totalCost '\
                                                                               'expense-claim.totalCost' }
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
    { id: form_field_id(field_name),
      class: form_field_class(field_name.to_sym),
      placeholder: field_name.capitalize,
      data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' } }
  end

  # Generates a unique id for each field in the expense entry table
  def form_field_id(field_name)
    "expense_entry_#{field_name.to_s}_#{self.expense_entry.id || '_new'}"
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