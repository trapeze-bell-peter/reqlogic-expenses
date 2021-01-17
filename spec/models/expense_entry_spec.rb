# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpenseEntry, type: :model do
  describe '#unit_cost=' do
    subject(:expense_entry) { ExpenseEntry.new }

    context 'when the unit cost is passed in as a string with symbol' do
      before { expense_entry.unit_cost = '£100' }

      specify { expect(expense_entry.unit_cost).to eql Money.new(10000, :gbp) }
    end

    context 'when the unit cost is passed as a string without a symbol' do
      before { expense_entry.unit_cost = '100' }

      specify { expect(expense_entry.unit_cost).to eql Money.new(10000, :gbp) }
    end
  end
end
