# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class FileReceiptPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, file_receipt)
    super(view, file_receipt)
  end

  alias file_receipt model

  def render_for_modal
    view.image_tag file_receipt.attachments.first, class: 'img-fluid',
                                                   hidden: true,
                                                   data: { target: 'expense-entry.receiptImage' }
  end
end