# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an attachment' do |content_type|
  describe '#is_pdf?' do
    specify { expect(subject.is_pdf?).to eq(content_type == 'image/pdf') }
  end
end

RSpec.describe FileReceipt, type: :model do
  subject(:receipt) { FileReceipt.create!(expense_entry_id: expense_entry.id) }

  let!(:expense_claim) { FactoryBot.create :expense_claim_with_entries }
  let(:expense_entry) { expense_claim.expense_entries.first }

  describe 'adding a PDF receipt' do
    before do
      blob = ActiveStorage::Blob.create_after_upload!(io: File.open('spec/test_data/attachment.pdf'),
                                                      filename: 'attachment.pdf', content_type: 'image/pdf')
      receipt.source_file.attach(blob)
    end

    specify { expect(receipt.source_file).to be_attached }

    it 'converts the PDF to a JPG image for rendering' do
      expect(receipt.attachments.count).to eq(1)
    end
  end
end