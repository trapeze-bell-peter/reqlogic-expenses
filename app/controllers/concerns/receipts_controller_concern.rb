module ReceiptsControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_receipt, only: %i[update destroy]
    before_action :set_expense_entry
  end

  def update
    respond_to :html, :json, :js

    authorize! :edit, @expense_entry

    @receipt.update(receipt_params.except(:email_address)) ? success : failure
  end

  def destroy
    respond_to :html, :json, :js

    authorize! :destroy, @expense_entry

    @receipt.destroy ? success : failure
  end

  private

  def success
    render partial: 'expense_entries/expense_entry.haml', layout: false, status: :ok, content_type: 'text/html',
           locals: { expense_entry: @expense_entry }
  end

  def failure
    render partial: 'expense_entries/expense_entry.haml', layout: false, status: :unprocessable_entity,
           content_type: 'text/html', locals: { expense_entry: @expense_entry }
  end

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def set_expense_entry
    @expense_entry = ExpenseEntry.find(@receipt&.expense_entry_id || params[:expense_entry_id])
  end
end