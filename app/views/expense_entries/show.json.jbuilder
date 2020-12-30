json.extract! @expense_entry, :id, :date, :sequence, :category, :description, :project, :vat, :qty
json.total @expense_entry.unit_cost.format