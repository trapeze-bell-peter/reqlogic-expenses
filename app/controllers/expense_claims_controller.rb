# frozen_string_literal: true

# Controller for expense claim
class ExpenseClaimsController < ApplicationController
  before_action :set_expense_claim, only: %i[show edit update destroy export_excel]

  # GET /expense_claims
  # GET /expense_claims.json
  def index
    @expense_claims = ExpenseClaim.all
  end

  # GET /expense_claims/1
  # GET /expense_claims/1.json
  def show;
    @expense_claim.expense_entries.new if @expense_claim.expense_entries.count == 0
  end

  # GET /expense_claims/new
  #
  # Because of the way that the AJAX/Stimulus works, we create an expense claim as part of the new and the redirect
  # to the Edit.
  def new
    respond_to :html

    @expense_claim = ExpenseClaim.create(claim_date: Time.zone.today)
    redirect_to @expense_claim, notice: 'Expense claim was successfully created.'
  end

  # GET /expense_claims/1/edit
  def edit; end

  # PATCH/PUT /expense_claims/1
  # PATCH/PUT /expense_claims/1.json
  def update
    respond_to :json

    if @expense_claim.update(expense_claim_params)
      head :ok
    else
      render partial: 'expense_claim_key_data', layout: false, status: :ok, locals: { expense_claim: @expense_claim }
    end
  end

  # DELETE /expense_claims/1
  # DELETE /expense_claims/1.json
  def destroy
    @expense_claim.destroy
    respond_to do |format|
      format.html { redirect_to expense_claims_url, notice: 'Expense claim was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # GET /export_excel
  #
  # Generates the Excel file
  def export_excel
    send_data(@expense_claim.export_excel.stream.read, disposition: 'attachment', type: 'application/excel',
                                                       filename: @expense_claim.suggested_filename)
  end

  # POST /expense_claim/barclay_csv_import
  def barclay_csv_import
    respond_to :html

    if params[:file]
      new_expense_claim = ExpenseClaim.barclay_xlsx_import(params[:file])
      redirect_to new_expense_claim, notice: 'Expenses from Barclay Card imported!'
    else
      redirect_to(root_url, 'Please upload a CSV file')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_claim
    @expense_claim = ExpenseClaim.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_claim_params
    params.require(:expense_claim).permit(:description, :claim_date)
  end
end
