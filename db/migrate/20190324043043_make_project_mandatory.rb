class MakeProjectMandatory < ActiveRecord::Migration[5.2]
  def change
    change_column :expense_entries, :project, :string, null: false
  end
end
