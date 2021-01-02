require 'rails_helper'

RSpec.describe ExpenseClaim, type: :model do
  describe 'FactoryBot' do
    subject(:expense_claim) { FactoryBot.create :expense_claim_with_entries }

    it 'creates a set of correctly sequenced expense_entry records' do
      array_of_sequence_nrs = expense_claim.expense_entries.order(:sequence).pluck(:sequence)
      integer_sequence_array = (0...expense_claim.expense_entries.count).to_a

      expect(array_of_sequence_nrs).to eq integer_sequence_array
    end
  end
end