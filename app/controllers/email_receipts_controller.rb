class EmailReceiptsController < ApplicationController
  include ReceiptsControllerConcern

  def create
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    email_receipt = EmailReceipt.new(expense_entry: @expense_entry)
    email_receipt.update(receipt_params.except(:email_address)) ? success : failure
  end

  private

  def receipt_params
    params.require(:email_receipt).permit(:email_receipt_token, :email_address)
  end
end
