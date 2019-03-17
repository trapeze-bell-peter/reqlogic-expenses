class ExpenseClaimsController < ApplicationController
  before_action :set_expense_claim, only: [:show, :edit, :update, :destroy]

  # GET /expense_claims
  # GET /expense_claims.json
  def index
    @expense_claims = ExpenseClaim.all
  end

  # GET /expense_claims/1
  # GET /expense_claims/1.json
  def show
  end

  # GET /expense_claims/new
  def new
    @expense_claim = ExpenseClaim.new
  end

  # GET /expense_claims/1/edit
  def edit
  end

  # POST /expense_claims
  # POST /expense_claims.json
  def create
    @expense_claim = ExpenseClaim.new(expense_claim_params)

    respond_to do |format|
      if @expense_claim.save
        format.html { redirect_to @expense_claim, notice: 'Expense claim was successfully created.' }
        format.json { render :show, status: :created, location: @expense_claim }
      else
        format.html { render :new }
        format.json { render json: @expense_claim.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_claims/1
  # PATCH/PUT /expense_claims/1.json
  def update
    respond_to do |format|
      if @expense_claim.update(expense_claim_params)
        format.html { redirect_to @expense_claim, notice: 'Expense claim was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_claim }
      else
        format.html { render :edit }
        format.json { render json: @expense_claim.errors, status: :unprocessable_entity }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense_claim
      @expense_claim = ExpenseClaim.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_claim_params
      params.require(:expense_claim).permit(:description, :date)
    end
end
