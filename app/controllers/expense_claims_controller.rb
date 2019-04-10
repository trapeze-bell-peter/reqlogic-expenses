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
  def show; end

  # GET /expense_claims/new
  def new
    @expense_claim = ExpenseClaim.new
    @expense_claim.expense_entries.new
  end

  # GET /expense_claims/1/edit
  def edit; end

  # POST /expense_claims
  # POST /expense_claims.json
  def create
    @expense_claim = ExpenseClaim.new(expense_claim_params)

    respond_to :html

    if @expense_claim.save
      redirect_to @expense_claim, notice: 'Expense claim was successfully created.'
    else
      render :new
    end
  end

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
      format.html { redirect_to expense_claims_url, notice: 'Expense claim was successfully destroyed.' }
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
