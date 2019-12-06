# frozen_string_literal: true

# Concern shared across the EmailReceiptsController and the FileReceiptsController.  Provides common actions for
# both controllers, even though the path to the actions are different for the two classes of object.
module ReceiptsControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_expense_entry
    before_action :set_receipt, only: %i[update destroy]
  end

  # PUT /email_receipts/:id or PUT /file_receipts/:id
  #
  # Note, that authorization is done on the owning expense_entry rather than on the receipt itself.
  def update
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    success = @receipt.update(receipt_params.except(:email_address))
    render_updated_expense_entry(success)
  end

  # DELETE /email_receipts/:id or DELETE /file_receipts/:id
  #
  # Note, that authorization is done on the owning expense_entry rather than on the receipt itself.
  def destroy
    respond_to :html, :json, :js

    authorize! :destroy, @expense_entry

    @receipt.destroy ? head(:ok) : render_updated_expense_entry(false)
  end

  private

  # @api private
  def set_expense_entry
    @expense_entry = ExpenseEntry.find(@receipt&.expense_entry_id || params[:expense_entry_id])
  end

  # @api private
  def set_receipt
    @receipt = Receipt.find(params[:id])
  end
end