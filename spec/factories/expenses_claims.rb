# frozen_string_literal: true

FactoryBot.define do
  factory :expense_claim do
    description { 'Test Expense Claim' }
    claim_date { Date.today }
    user { User.find_by(email: 'test.user@trapezegroup.com') || FactoryBot.create(:test_user) }

    # user_with_posts will create post data after the user has been created
    factory :expense_claim_with_entries do
      # posts_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        expense_entries_count { 5 }
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |expense_claim, evaluator|
        create_list(:expense_entry, evaluator.expense_entries_count, expense_claim: expense_claim)
      end
    end
  end
end