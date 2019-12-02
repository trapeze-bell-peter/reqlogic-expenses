# frozen_string_literal: true

# Controller for FileReceipts.  Invoked from the Receipt modal.  As much of the functionality is shared between
# the different types of receipts, this has been implemented in FileReceiptsController
class FileReceiptsController < ApplicationController
  include ReceiptsControllerConcern

  # POST /expenses_entries/:expense_entry_id/file_receipts
  def create
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    file_receipt = FileReceipt.new(expense_entry: @expense_entry)
    file_receipt.update(file_receipt_params) ? success : failure
  end

  private

  def receipt_params
    params.require(:file_receipt).permit(:source_file, :image_receipt_url)
  end
end
