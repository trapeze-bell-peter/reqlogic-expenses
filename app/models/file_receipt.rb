# frozen_string_literal: true

# Used to store details of a receipt either uploaded or fetched from Google Photo.
class FileReceipt < Receipt

  def self.convert_existing_pdfs
    FileReceipt.all.each do |file_receipt|
      file_receipt.attachments.each do |attachment|
        if Receipt.is_pdf?(attachment)
          file_receipt.convert_pdf_to_jpgs(attachment, attachment.blob)
        end
      end
    end
  end
end