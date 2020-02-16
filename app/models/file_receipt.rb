# frozen_string_literal: true

# Used to store details of a receipt either uploaded or fetched from Google Photo.
class FileReceipt < Receipt
  has_one_attached :source_file

  delegate :sequence, :description, to: :expense_entry
  
  EMAIL_NOTIFICATION_CLASS = '"alert alert-success alert-block"'

  before_save { |receipt| @pdf_conversion_needed = receipt.source_file.changed? && receipt.pdf? }
  after_commit do |receipt|
    receipt.convert_pdf_to_jpgs(receipt.source_file, receipt.source_file.blob) if @pdf_conversion_needed
  end

  # Because of the way that the upload mechanisms work, things are async, so we check wether we have an upload
  def arrived?
    self.source_file.attached?
  end

  # Used to receive an image from Google.
  def image_receipt_url=(url)
    document = Nokogiri::HTML(URI.open(url))
    google_image_url = document.css('meta[property="og:image"]').attribute('content').value
    google_image_url = %r{(https://.*\.googleusercontent.com/.*)=w[0-9]+-h[0-9]+.+}.match(google_image_url)[1]
    source_file.attach(io: URI.open(google_image_url), filename: "Receipt for #{self.sequence}", content_type: 'image/jpeg')

    NotificationsChannel.broadcast_to(
      self.user_id,
      expense_entry_id: self.expense_entry_id,
      msg_html: "<div class=#{EMAIL_NOTIFICATION_CLASS}>Google image retrieved for #{self.description}</div>"
    )
  end

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