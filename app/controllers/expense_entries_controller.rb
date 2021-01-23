# frozen_string_literal: true

# Used to provide actions on a single expense entry row.  The frontend works by sending changes to individual
# rows.  These are processed by this controller.
class ExpenseEntriesController < ActionController::API
  before_action :set_expense_entry, only: %i[show update]

  # GET /expense_entries/1.json
  def show; end

  # POST /expense_entries.json
  def create
    @expense_entry = ExpenseEntry.create(expense_entry_params)
    head :ok
  end

  # PATCH/PUT /expense_entries/1.json
  def update
    update_successful = @expense_entry.update(expense_entry_params)

    if update_successful && expense_entry_params['receipt']
      @expense_entry.receipt.attach(expense_entry_params['receipt'])
    elsif update_successful
      head :ok
    else
      render status: :unprocessable_entity, json: { errors: @expense_entry.errors }
    end
  end

  # DELETE /expense_entries/1.json
  def destroy
    respond_to :html, :json, :js

    @expense_entry.destroy

    head :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_entry
    @expense_entry = ExpenseEntry.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_entry_params
    params.require(:expense_entry)
          .permit(:expense_claim_id, :sequence, :date, :category_id, :description, :project, :vat, :qty, :unit_cost,
                  :receipt, :email_receipt_token, :image_receipt_url)
  end
end
