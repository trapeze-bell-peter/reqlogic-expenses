# frozen_string_literal: true

# Used to store details of a receipt either uploaded or fetched from Google Photo.
class FileReceipt < Receipt

  def self.convert_existing_pdfs
    FileReceipt.all.each do |file_receipt|
      file_receipt.attachments.each do |attachment|
    end
  end
end