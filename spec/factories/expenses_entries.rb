# frozen_string_literal: true

FactoryBot.define do
  factory :expense_entry do
    date                { expense_claim.claim_date - 10.days }
    category            { 'FARES' }
    description         { 'Test Expense Entry' }
    project             { 'EXPENSES'}
    vat                 { 0 }
    qty                 { 1 }
    unit_cost           { Money.new('£ 5.00') }

    factory :expense_entry_for_email do
      email_receipt_token { 'u2iclhr1' }
    end

    before(:create, &:set_sequence)
  end
end