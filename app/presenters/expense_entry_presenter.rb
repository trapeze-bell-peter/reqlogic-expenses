# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class ExpenseEntryPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry)
    super(view)
    @expense_entry = expense_entry
  end

  attr_reader :expense_entry

  def row_id
    "expense-entry-#{expense_entry.persisted? ? expense_entry.id : 'empty-row'}"
  end

  def form(ajax_actions)
    view.form_with model: expense_entry, class: 'form',
                   data: { controller: 'expense-form', action: "change->expense-form#changeEvent #{ajax_actions}",
                           expense_form_change_pending: '0', target: 'expense-rows.form', type: 'json' } do |expense_entry_form|
                        @expense_entry_form = expense_entry_form
                        yield(expense_entry_form)
                      end
  end

  attr_reader :expense_entry_form

  def expense_claim_id
    expense_entry_form.hidden_field :expense_claim_id
  end

  def sequence
    expense_entry_form.hidden_field :sequence, data: { target: 'expense-rows.sequenceField' }
  end

  # Renders a date field for the expense entry form
  def date
    expense_entry_form.date_field :date, class: 'form-control', placeholder: 'Date'
  end

  # Renders a selector for the different categories
  def categories
    expense_entry_form.select :category,
                              view.options_for_select(options_list, expense_entry.category),
                              { placeholder: 'Category', required: true },
                              { class: 'form-control', data: { action: 'change->expense-form#categoryChange' } }
  end

  # Renders a text field for the description
  def description
    expense_entry_form.text_field :description, class: 'form-control', placeholder: 'Description'
  end

  # Renders a text field for the description
  # @todo replace with a lookup based on JET data
  def project
    expense_entry_form.text_field :project, class: 'form-control', placeholder: 'Project code'
  end

  def vat
    expense_entry_form.select :vat, %w[0 20], { placeholder: 'Category', required: true },
                              { class: 'form-control', data: { target: 'expense-form.vat' } }
  end

  def qty
    expense_entry_form.number_field :qty, class: 'form-control', required: true, min: '1',
                                          data: { action: 'change->expense-form#recalcClaim', target: 'expense-form.qty' }
  end

  def unit_cost
    expense_entry_form.number_field :unit_cost, class: 'form-control', required: true, min: '0.01', step: '0.01',
                                                data: { action: 'keyup->expense-form#recalcClaim change->expense-form#recalcClaim',
                                                        target: 'expense-form.unitCost' }
  end

  def total_cost
    view.text_field_tag :total_cost,
                        expense_entry.vat * expense_entry.qty,
                        disabled: true,
                        class: 'form-control', data: { target: 'expense-form.totalCost expense-rows.totalCost' }
  end

  def delete_button
    if expense_entry.persisted?
      view.link_to(view.expense_entry_path(expense_entry),
                   method: :delete, remote: true, data: { action: 'ajax:success->expense-entry#deleteRow' },
                   &method(:delete_icon))
    else
      view.link_to('_', href: '#', data: { action: 'click->expense-entry#deleteRow' }, &method(:delete_icon))
    end
  end

  def insert_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-entry#insertRow' }) do
      view.tag.i class: 'fas fa-plus-square fa-2x expenses-action-icon'
    end
  end

  def copy_button
    view.link_to(view.new_expense_entry_path(expense_claim_id: expense_entry.expense_claim_id),
                 data: { action: 'click->expense-entry#copyRow' }) do
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