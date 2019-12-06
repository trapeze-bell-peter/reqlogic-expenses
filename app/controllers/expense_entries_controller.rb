# frozen_string_literal: true

# Used to provide actions on a single expense entry row.  The frontend Stimulus works by sending changes to individual
# rows.  These are processed by this controller.  Depending on the action and the outcome, a revised expense entry may
# row be returned.
class ExpenseEntriesController < ApplicationController
  include ExpenseEntryRenderConcern

  load_and_authorize_resource param_method: :expense_entry_params, only: %i[edit update destroy]

  # GET /expense_entries/new
  def new
    respond_to :html

    @expense_entry = ExpenseEntry.new(new_expense_entry_params)
    authorize! :manage, @expense_entry

    render partial: 'expense_entry', layout: false, status: :ok, locals: { expense_entry: @expense_entry }
  end

  # GET /expense_entries/1/edit
  def edit
    render_updated_expense_entry(@expense_entry)
  end

  # POST /expense_entries
  # POST /expense_entries.json
  def create
    authorize! :manage, ExpenseClaim.find(expense_entry_params[:expense_claim_id])

    @expense_entry = ExpenseEntry.create(expense_entry_params)

    render_updated_expense_entry(@expense_entry.valid?)
  end

  # PATCH/PUT /expense_entries/1.json
  def update
    respond_to :html, :json, :js

    update_successful = @expense_entry.update(expense_entry_params)

    if update_successful && expense_entry_params['receipt']
      @expense_entry.receipt.attach(expense_entry_params['receipt'])
      render_updated_expense_entry(true)
    elsif update_successful
      head :ok
    else
      render_updated_expense_entry(false)
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

  def new_expense_entry_params
    params.permit(:expense_claim_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_entry_params
    params.require(:expense_entry)
          .permit(:expense_claim_id, :sequence, :date, :category, :description, :project, :vat, :qty, :unit_cost,
                  :receipt, :email_receipt_token, :image_receipt_url)
  end
end
