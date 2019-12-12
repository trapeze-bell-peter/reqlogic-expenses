# frozen_string_literal: true

# Controller for FileReceipts.  Invoked from the Receipt modal.  As much of the functionality is shared between
# the different types of receipts, this has been implemented in ReceiptControllerConcern.
class FileReceiptsController < ApplicationController
  include ExpenseEntryRenderConcern
  include ReceiptsControllerConcern

  # POST /expenses_entries/:expense_entry_id/file_receipts
  def create
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    file_receipt = FileReceipt.new(expense_entry: @expense_entry)
    success = file_receipt.update(receipt_params)
    render_updated_expense_entry(success)
  end

  private

  # Note that the ReceiptsControllerConcern uses the method receipt_params to check the incoming params.  This
  # differs for EmailReceipt and for FileReceipt.
  def receipt_params
    params.require(:file_receipts).permit(:source_file, :image_receipt_url, :receipt_size)
  end
end
