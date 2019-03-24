# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class ExpenseEntryPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry_form)
    super(view)
    @expense_entry_form = expense_entry_form
  end

  attr_reader :expense_entry_form

  # Renders a date field for the expense entry form
  def date
    expense_entry_form.date_field :date, class: 'form-control', placeholder: 'Date'
  end

  # Renders a selector for the different categories
  def categories
    expense_entry_form.select :category,
                              view.options_for_select(options_list),
                              { include_blank: 'Category', required: true },
                              { class: 'form-control', data: { action: 'change->expenses#categoryChange' } }
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
    expense_entry_form.number_field :vat, class: 'form-control', data: { target: 'expenses.vat' }
  end

  def qty
    expense_entry_form.number_field :qty, class: 'form-control', required: true, min: '1',
                                          data: { action: 'change->expenses#recalcClaim', target: 'expenses.qty' }
  end

  def unit_cost
    expense_entry_form.number_field :unit_cost, class: 'form-control', required: true, min: '0.01', step: '0.01',
                                                data: { action: 'change->expenses#recalcClaim',
                                                        target: 'expenses.unitCost' }
  end

  def total_cost
    view.number_field_tag :total_cost,
                          expense_entry_form.object.vat * expense_entry_form.object.qty,
                          disabled: true, class: 'form-control', data: { target: 'expenses.totalCost' }
  end

  def delete_button(&block)
    if expense_entry_form.object.persisted?
      view.link_to(view.expense_entry_path(expense_entry_form.object),
                   method: :delete, remote: true, data: { action: 'ajax:success->expenses#deleteRow' },
                   &block)
    else
      view.link_to('_', href: '#', data: { action: 'click->expenses#deleteRow' },&block)
    end
  end

  private

  def options_list
    Category.order(:name).each_with_object([]) do |category, options_array|
      options_array << [category.name, category.name,
                        {}, data: { vat: category.vat, unitCost: category.unit_cost.to_s }]
    end
  end
end