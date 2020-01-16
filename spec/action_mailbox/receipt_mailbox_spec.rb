require 'rails_helper'

RSpec.describe ReceiptMailbox, type: :mailbox do
  describe 'HTML email with attached PDF' do
    subject { receive_inbound_email_from_source(File.read('spec/test_data/receipt.rfc822')) }

    let!(:expense_claim) { FactoryBot.create :expense_claim_with_entries }

    it 'correctly matches the incoming email to the expense entry' do
      expect { subject }.to change(EmailReceipt, :count).by(1)
    end

    it 'identifies the PDF as not being an embedded image' do
      subject
      expect(expense_entry.email_receipt.embedded_images.count).to eq 0
    end
  end

  describe 'HTML email encoded in Base64 with PDF receipt attached' do
    subject!(:expense_claim) { FactoryBot.create :expense_claim_with_email_receipt }

    let(:email) { receive_inbound_email_from_source(File.read('spec/test_data/allan_receipt.rfc822')) }
    let(:email_receipt) { expense_claim.expense_entries.first.receipt }

    it 'correctly stores the incoming email with attachments' do
      pending 'HTML comparison still needs sorting properly'
      
      expect(email.mail.to.first).to eq("receipt-development.#{email_receipt.email_receipt_token}@tguk-expenses.com")
      puts CompareXML.equivalent?(Nokogiri::HTML(email_receipt.email_body), Nokogiri::HTML(email.mail.html_part.decoded), verbose: true)
      expect(CompareXML.equivalent?(Nokogiri::HTML(email_receipt.email_body), Nokogiri::HTML(email.mail.html_part.decoded))).to be_truthy
    end
  end

  describe 'Upload of image removes existing image and email receipt' do
    skip
  end

  describe 'Receiving email receipt removes existing image and email receipt' do
    skip
  end
end