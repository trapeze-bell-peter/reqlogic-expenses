json.extract! @expense_entry, :id, :date, :sequence, :description, :category_id, :project, :vat, :qty
json.unit_cost @expense_entry.unit_cost.format