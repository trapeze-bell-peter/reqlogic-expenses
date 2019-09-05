class ExpenseEntriesController < ApplicationController
  load_and_authorize_resource param_method: :expense_entry_params, only: %i[edit update destroy]

  # GET /expense_entries/new
  def new
    respond_to :html

    @expense_entry = ExpenseEntry.new(new_expense_entry_params)

    authorize! :manage, @expense_entry

    render partial: 'expense_entry', layout: false, status: :ok,
           locals: { expense_entry: @expense_entry, expense_claim: @expense_claim }
  end

  # GET /expense_entries/1/edit
  def edit
    render partial: 'expense_entry', layout: false, status: (@expense_entry ? :ok : :unprocessable_entity),
           locals: { expense_entry: @expense_entry, expense_claim: @expense_claim }
  end

  # POST /expense_entries
  # POST /expense_entries.json
  def create
    @expense_entry = ExpenseEntry.create(expense_entry_params)

    authorize! :manage, @expense_entry

    render partial: 'expense_entry', layout: false, status: (@expense_entry.valid? ? :ok : :unprocessable_entity),
           content_type: 'text/html', locals: { expense_entry: @expense_entry, expense_claim: @expense_claim }
  end

  # PATCH/PUT /expense_entries/1.json
  def update
    respond_to :html, :json, :js

    if @expense_entry.update(expense_entry_params)
      head :ok
    else
      render partial: 'expense_entry.haml', layout: false, status: :unprocessable_entity, content_type: 'text/html',
             locals: { expense_entry: @expense_entry, expense_claim: @expense_claim }
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
                  :receipt)
  end
end
