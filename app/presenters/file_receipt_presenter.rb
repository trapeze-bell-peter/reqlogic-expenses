# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class FileReceiptPresenter < BasePresenter
  include UploadFormPresenter

  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  # @param [FileReceipt] file_receipt
  def initialize(view, file_receipt)
    super(view, file_receipt)
  end

  alias file_receipt model
  delegate :source_file, :attachments, to: :file_receipt

  # Generates the relevant image tag to be used by the modal to show the existing receipt image.  If the source
  # file is an image, use that.  If not, then use the first of the attachments.
  #
  # @return [Void]
  def render_for_modal
    image = self.source_file.attachment&.image? ? self.source_file : self.attachments.first

    return if image.nil?

    view.image_tag image, class: 'img-fluid', hidden: true, data: { target: 'expense-entry.receiptImage' }
  end
end