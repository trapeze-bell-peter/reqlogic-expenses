json.extract! expense_claim, :id, :description, :claim_date, :first_date, :last_date, :created_at, :updated_at
json.total expense_claim.total.format
json.url expense_claim_url(expense_claim, format: :json)