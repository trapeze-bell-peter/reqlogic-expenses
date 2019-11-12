# frozen_string_literal: true

require 'convert_api'
require 'uri'

# Processing of incoming receipt emails.
class ReceiptMailbox < ApplicationMailbox
  include Rails.application.routes.url_helpers

  attr_reader :expense_entry
  attr_reader :attachments

  # Check we are able to process this email as it matches an expense_entry and the user we are receiving from is
  # valid.
  before_processing do
    email_receipt_token =
      /^receipt(-(development|staging))?.([[:alnum:]]{8})@tguk-expenses\.com$/.match(mail.to.first)[3]
    @expense_entry = ExpenseEntry.find_by(email_receipt_token: email_receipt_token)
    bounced! unless @expense_entry && sender_is_claimant?
  end

  # Check that the sender of the email matches the claimant.
  def sender_is_claimant?
    mail.from.first == @expense_entry.expense_claim.user.email
  end

  # Process the inbound email.  If a receipt is already attached to the expense_entry, then the new email replaces this
  # email receipt.  If not, a new email receipt is created.  Likewise, if a receipt image is attached to the expense
  # entry then this is purged first.
  #
  # Any attachments of the incoming email are saved to ActiveStorage. If the attachment is a PDF it is converted into a
  # series of JPG files replacing the original PDF.  This allows us to render the original PDF in the print out of the
  # expenses.
  #
  # Emails in HTML get special treatment.  We start by parsing its content if it is HTML into @document.
  #
  # For HTML emails, the body is scanned for any embedded images.  References to these are replaced with references
  # to the Blob held in Rails.  This way we can render the email with embedded images.
  #
  # mail => Mail object
  # inbound_email => ActionMailboxEmail record
  #
  # @return [Void]
  def process
    @document = Nokogiri::HTML(mail.html_part.body.decoded) if mail.multipart? && mail.html_part

    @email_receipt = expense_entry.email_receipt || expense_entry.build_email_receipt
    @email_receipt.title = mail.subject
    @email_receipt.embedded_images = []

    expense_entry.destroy_receipt
    attachments_in_email_receipt
    extract_body
    @email_receipt.save!
  end

  private

  # Extracts the attachments, saves them to ActiveStorage and returns an array of the Blobs holding the extracted
  # images
  #
  # @api private
  # @return [Array<ActiveStorage::Blob>]
  def attachments_in_email_receipt
    mail.attachments.each do |attachment|
      blob = ActiveStorage::Blob.create_after_upload!(io: StringIO.new(attachment.body.to_s),
                                                      filename: attachment.filename,
                                                      content_type: attachment.content_type)

      if attachment.content_type =~ /^application\/pdf/ || attachment.filename =~ /\.pdf$/i
        convert_pdf_to_jpgs(attachment, blob)
      elsif mail.multipart? && mail.html_part
        replace_embedded_image_in_html(attachment, blob)
      end
    end
  end

  # Goes through all the attachments in the incoming email.  If the attachment is a PDF use web service to get convert
  # it to JPG so we can print it out later.
  #
  # @param [ActiveStorage::Attachment] attachment - details of the attachment
  # @param [ActiveStorage::Blob] blob the associated blob for the attachment
  # @return [Array<ActiveStorage::Blob>] array of the JPG images converted from the PDF
  def convert_pdf_to_jpgs(attachment, blob)
    pdf_url = blob.service_url
    jpgs = ConvertApi.convert('jpg', { File: pdf_url }, from_format: 'pdf')
    jpgs.response['Files'].each_with_index do |jpg_file, page|
      @email_receipt.attachments.attach(io: URI.open(jpg_file['Url']),
                                        filename: "#{attachment.filename} - Page #{page + 1}",
                                        content_type: 'image/jpeg')

    end
  end

  # Replace the HTML for embedded images associated with the specific attachment with a reference to the Blob in
  # in active storage.
  #
  # @api private
  #
  # @param [ActiveStorage::Attachment] attachment - details of the PDF attachment
  # @param [ActiveStorage::Blob] blob the associated blob for the PDF attachment
  # @return [Void]
  def replace_embedded_image_in_html(attachment, blob)
    # Remove the beginning and end < >
    content_id = attachment.content_id[1...-1]

    element = @document.at_css("img[src='cid:#{content_id}']")

    return unless element

    @document.at_css("img[src='cid:#{content_id}']")&.attributes['src'] = url_for(attachment)
    @email_receipt.embedded_images << blob.id
  end

  # Extracts the body of the email text.  If HTML ensures it is encoded in UTF-8.
  def extract_body
    @email_receipt.email_body =
      if mail.multipart? && mail.html_part
        @document.at_css('body').inner_html.encode('utf-8')
      elsif mail.multipart? && mail.text_part
        mail.text_part.body.decoded
      else
        mail.decoded
      end
  end
end
