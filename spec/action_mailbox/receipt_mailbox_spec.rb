require 'rails_helper'

RSpec.describe ReceiptMailbox, type: :mailbox do
  describe 'HTML email with attached PDF' do
    subject { receive_inbound_email_from_source(File.read('spec/test_data/receipt.rfc822')) }

    let!(:expense_entry) { FactoryBot.create :expense_entry_for_email }

    it 'correctly matches the incoming email to the expense entry' do
      expect { subject }.to change(EmailReceipt, :count).by(1)
    end

    it 'identifies the PDF as not being an embedded image' do
      subject
      expect(expense_entry.email_receipt.embedded_images.count).to eq 0
    end
  end

  describe 'Upload of image removes existing image and email receipt' do
    skip
  end

  describe 'Receiving email receipt removes existing image and email receipt' do
    skip
  end
end