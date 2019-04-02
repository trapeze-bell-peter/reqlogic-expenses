class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :vat
      t.monetize :unit_cost

      t.timestamps
    end
  end
end
