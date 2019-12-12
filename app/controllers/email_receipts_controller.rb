# frozen_string_literal: true

# Invoked when the user presses the 'Copy to buffer' in the Receipt modal.  Sends the generated token to here,
# where we then store it in a newly created email receipt.
class EmailReceiptsController < ApplicationController
  include ExpenseEntryRenderConcern
  include ReceiptsControllerConcern

  # POST /email_receipts
  def create
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    email_receipt = EmailReceipt.new(expense_entry: @expense_entry)
    success = email_receipt.update(receipt_params.except(:email_address))
    render_updated_expense_entry(success)
  end

  private

  # Note that the ReceiptsControllerConcern uses the method receipt_params to check the incoming params.  This
  # differs for EmailReceipt and for FileReceipt.
  def receipt_params
    params.require(:email_receipts).permit(:email_receipt_token, :email_address)
  end
end
