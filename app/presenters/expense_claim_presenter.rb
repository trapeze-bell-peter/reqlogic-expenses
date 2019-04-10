# frozen_string_literal: true

# Used to generate key fields for the Expense Claim HTML page.  These are the global fields at the top of the page.
class ExpenseClaimPresenter < StimulusFormPresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_claim)
    super(view, expense_claim)
  end

  alias_method :expense_claim, :model

  # Generates, based on the field name, the default hash that the form field would use.
  #
  # @api private
  # @param [String] field_name
  # @return [Hash]
  def default_field_hash(field_name)
    { class: form_field_class(field_name.to_sym),
      placeholder: field_name.capitalize,
      data: { action: 'change->expense-claim#changeClaim' }
    }
  end
end