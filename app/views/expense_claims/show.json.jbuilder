json.extract! @expense_claim, :id, :description, :claim_date
json.total @expense_claim.total.format

json.expense_entries do
  json.array! @expense_claim.expense_entries do |expense_entry|
    json.partial! 'expense_entries/expense_entry', expense_entry: expense_entry
  end
end
