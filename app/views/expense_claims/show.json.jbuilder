json.extract! @expense_claim, :id, :description, :claim_date
json.total @expense_claim.total.format
