# frozen_string_literal: true

FactoryBot.define do
  factory :expense_claim do
    description { 'Test Expense Claim' }
    claim_date { Date.today }

    user { User.find_by(email: 'test.user@trapezegroup.com') || FactoryBot.create(:test_user) }
  end
end