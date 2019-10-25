# frozen_string_literal: true

FactoryBot.define do
  factory :expense_entry do
    factory :expense_entry_for_email do
      expense_claim       { ExpenseEntry.find_by(description: '') || FactoryBot.create(:expense_claim) }
      date                { expense_claim.claim_date - 10.days }
      add_attribute(:sequence) { 1 }
      category            { 'FARES' }
      description         { 'Test Expense Entry' }
      project             { 'EXPENSES'}
      vat                 { 0 }
      qty                 { 1 }
      unit_cost           { Money.new('£ 5.00') }
      email_receipt_token { 'u2iclhr1' }
    end
  end
end