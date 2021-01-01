json.extract! @expense_entry, :id, :date, :sequence, :description, :category_id, :project, :vat, :qty
json.total @expense_entry.unit_cost.format