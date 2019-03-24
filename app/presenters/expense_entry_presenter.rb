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
  # @return [ActionView::DateField]
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

  private

  def options_list
    Category.order(:name).each_with_object([]) do |category, options_array|
      options_array << [category.name, category.name,
                        {}, data: { vat: category.vat, unitCost: category.unit_cost.to_s }]
    end
  end
end