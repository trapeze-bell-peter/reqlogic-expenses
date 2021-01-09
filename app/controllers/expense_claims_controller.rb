# frozen_string_literal: true

# Controller for expense claim.
class ExpenseClaimsController < ActionController::API
  before_action :set_expense_claim, only: %i[show update]

  # GET /expense_claims.json
  def index
    @expense_claims = ExpenseClaim.sorted_claims
  end

  # GET /expense_claims/1.json
  def show; end

  # PATCH/PUT /expense_claims/1
  # PATCH/PUT /expense_claims/1.json
  def update
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
  #
  # Used to receive a CSV export from the Barclay card site, and process it.
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

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_claim
    @expense_claim = ExpenseClaim.includes(:expense_entries).order('expense_entries.sequence').find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_claim_params
    params.require(:expense_claim).permit(:description, :claim_date)
  end
end
