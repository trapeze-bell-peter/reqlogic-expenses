# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class EmailReceiptPresenter < BasePresenter
  include UploadFormPresenter

  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, email_receipt)
    super(view, email_receipt)
  end

  alias email_receipt model

  def render_for_modal
    if email_receipt.attachments.first
      view.image_tag email_receipt.attachments.first, class: 'email-in-modal img-fluid', hidden: true,
                                                      data: { target: 'expense-entry.receiptImage' }
    elsif email_receipt.email_body
      view.tag.div email_receipt.email_body.html_safe, class: 'email-in-modal overflow-auto', hidden: true,
                                                       data: { target: 'expense-entry.receiptImage' }
    end
  end
end