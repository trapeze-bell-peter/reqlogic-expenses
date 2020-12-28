json.extract! @expense_entry, :id, :expense_claim_id, :date, :sequence, :category, :description, :project, :vat, :qty
json.total @expense_entry.unit_cost.format