# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class EmailReceiptPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, email_receipt)
    super(view, email_receipt)
  end

  alias email_receipt model

  def render_for_modal
    # view.image_tag email_receipt.attachments.first, class: 'img-fluid',
    #                hidden: true,
    #                data: { target: 'expense-entry.receiptImage' }
  end
end