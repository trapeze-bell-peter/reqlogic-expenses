# frozen_string_literal: true

# Used to store details of a receipt either uploaded or fetched from Google Photo.
class FileReceipt < Receipt
  def self.move_receipt_images
    ActiveStorage::Attachment.where(record_type: 'ExpenseEntry').each do |receipt_attachment|
      file_receipt = FileReceipt.create!(expense_entry_id: receipt_attachment.record_id)
      receipt_attachment.update!(record_id: file_receipt.id, record_type: 'Receipt', name: 'attachments')
    end
  end
end