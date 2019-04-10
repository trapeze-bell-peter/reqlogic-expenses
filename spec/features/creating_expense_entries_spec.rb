# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an expense entry', type: :feature do
  describe 'create a completely new expense claim', js: true do
    before do
      visit 'expense_claims/new'

      fill_in 'Claim date', with: Date.today - 10.days
      fill_in 'Description', with: 'Test expenses claim'

      fill_in '#expense_entry_date', with: Date.today - 20.days
      click 'Back'
    end

    scenario do
      expenses_claim = ExpenseClaim.first
      expect(expenses_claim.claim_date).to eq(Date.today - 10.days)
      expect(expenses_claim.description).to eq('Test expenses claim')
      expenses_entry = ExpenseClaim.expenses_entries.first
      expect(expenses_entry.date).to eq(Date.today - 20.days)
    end
  end
end
