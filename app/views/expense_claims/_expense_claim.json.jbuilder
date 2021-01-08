json.extract! expense_claim, :id, :description, :claim_date, :from_date, :to_date, :created_at, :updated_at
json.total expense_claim.total.format
json.url expense_claim_url(expense_claim, format: :json)

if include_expense_entries
  json.expense_entries do
    json.array! expense_claim.expense_entries do |expense_entry|
      json.partial! 'expense_entries/expense_entry', expense_entry: expense_entry
    end
  end
end