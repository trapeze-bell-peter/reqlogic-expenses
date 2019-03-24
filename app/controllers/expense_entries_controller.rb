class ExpenseEntriesController < ApplicationController
  before_action :set_expense_entry, only: %i[edit update destroy]

  # GET /expense_entries/new
  def new
    respond_to :html

    @expense_entry = ExpenseEntry.new
    @expense_claim = ExpenseClaim.find(new_expense_entry_params)

    render :new, layout: false
  end

  # GET /expense_entries/1/edit
  def edit
    @expense_entry.new
  end

  # POST /expense_entries
  # POST /expense_entries.json
  def create
    @expense_entry = ExpenseEntry.new(expense_entry_params)

    respond_to do |format|
      if @expense_entry.save
        format.html { redirect_to @expense_entry, notice: 'Expense entry was successfully created.' }
        format.json { render :show, status: :created, location: @expense_entry }
      else
        format.html { render :new }
        format.json { render json: @expense_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_entries/1.json
  def update
    respond_to :json

    if @expense_entry.update(expense_entry_params)
      render json: @expense_entry, status: :ok
    else
      render json: @expense_entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /expense_entries/1.json
  def destroy
    respond_to :html, :json, :js

    # @expense_entry.destroy

    head :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_entry
    @expense_entry = ExpenseEntry.find(params[:id])
  end

  def new_expense_entry_params
    params.require(:expense_claim_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_entry_params
    params.require(:expense_entry).permit(:date, :category, :description, :vat, :qty, :unit_cost)
  end
end
