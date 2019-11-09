# frozen_string_literal: true

# Controller for expense claim
class ExpenseClaimsController < ApplicationController
  load_and_authorize_resource param_method: :expense_claim_params

  # GET /expense_claims
  # GET /expense_claims.json
  def index; end

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

    @expense_claim = ExpenseClaim.create(claim_date: Time.zone.today, user: current_user)
    redirect_to edit_expense_claim_path(@expense_claim), notice: 'Expense claim was successfully created.'
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
      new_expense_claim = BarclayCardImporter.run(params[:file], current_user)
      redirect_to new_expense_claim, notice: 'Expenses from Barclay Card imported!'
    else
      redirect_to(root_url, 'Please upload a CSV file')
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_claim_params
    params.require(:expense_claim).permit(:description, :claim_date)
  end
end
