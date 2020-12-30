# frozen_string_literal: true

namespace :deployment do
  desc 'Move category on expense_entries from string to reference'
  task make_category_ref: :environment do
    categories = Category.select(:name, :id)
                         .to_a
                         .each_with_object({}) { |category, category_map| category_map[category.name] = category.id }

    ExpenseEntry.all.each do |expense_entry|
      expense_entry.update!(category_id: categories[expense_entry.category_string])
    end
  end
end