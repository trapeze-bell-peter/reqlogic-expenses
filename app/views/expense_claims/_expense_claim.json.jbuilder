json.extract! expense_claim, :id, :description, :claim_date, :created_at, :updated_at
json.url expense_claim_url(expense_claim, format: :json)
