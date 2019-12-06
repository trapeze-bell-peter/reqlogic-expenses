# frozen_string_literal: true

# Concern shared across the ExpenseEntryController, EmailReceiptsController and the FileReceiptsController.
# When changes or an error have occurred to an expense_entry row, the backend sends a expense entry HTML slug back for
# the frontend to replace the existing row with.
module ExpenseEntryRenderConcern
  extend ActiveSupport::Concern

  private

  # Once the action has been carried out, an updated expense_entry row is sent back to the browser.  The browser
  # replaces the previous row with the new row.  If the update or delete failed, then the returned row contains
  # error information.
  #
  # @api private
  # @param [Boolean] success
  def render_updated_expense_entry(success)
    return_status = success ? :ok : :unprocessable_entity
    render partial: 'expense_entries/expense_entry.haml', layout: false, status: return_status,
           content_type: 'text/html', locals: { expense_entry: @expense_entry }
  end
end