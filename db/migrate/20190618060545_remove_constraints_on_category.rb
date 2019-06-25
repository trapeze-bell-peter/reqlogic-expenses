class RemoveConstraintsOnCategory < ActiveRecord::Migration[5.2]
  def change
    change_column_null :categories, :unit_cost_pence, true
    change_column_default :categories, :unit_cost_pence, nil
  end
end
