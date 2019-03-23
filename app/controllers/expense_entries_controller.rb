class ExpenseEntriesController < ApplicationController
  before_action :set_expense_entry, only: %i[edit update destroy]

  # GET /expense_entries/new
  def new
    @expense_entry = ExpenseEntry.new
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

  # PATCH/PUT /expense_entries/1
  # PATCH/PUT /expense_entries/1.json
  def update
    respond_to :json

    if @expense_entry.update(expense_entry_params)
      render json: @expense_entry, status: :ok
    else
      render json: @expense_entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /expense_entries/1
  # DELETE /expense_entries/1.json
  def destroy
    @expense_entry.destroy
    respond_to do |format|
      format.html { redirect_to expense_entries_url, notice: 'Expense claim was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_entry
    @expense_entry = ExpenseEntry.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_entry_params
    params.require(:expense_entry).permit(:date, :category, :description, :vat, :qty, :unit_cost)
  end
end
