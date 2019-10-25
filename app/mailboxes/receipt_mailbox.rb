# frozen_string_literal: true

require 'open-uri'
require 'convert_api'

# Processing of incoming receipt emails.
class ReceiptMailbox < ApplicationMailbox
  include Rails.application.routes.url_helpers

  attr_reader :expense_entry
  attr_reader :attachments

  # Check we are able to process this email as it matches an expense_entry and the user we are receiving from is
  # valid
  before_processing do
    email_receipt_token = /^receipt(-(development|staging))?.([[:alnum:]]{8})@tguk-expenses\.com$/.match(mail.to.first)[3]
    @expense_entry = ExpenseEntry.find_by(email_receipt_token: email_receipt_token)
    bounced! unless @expense_entry && sender_is_claimant?
  end

  # Check that the sender of the email matches the claimant.
  def sender_is_claimant?
    mail.from.first == @expense_entry.expense_claim.user.email
  end

  # mail => Mail object
  # inbound_email => ActionMailboxEmail record
  def process
    @document = Nokogiri::HTML(mail.html_part.body.decoded) if mail.multipart? && mail.html_part

    @email_receipt = expense_entry.email_receipt || expense_entry.build_email_receipt
    @email_receipt.title = mail.subject
    @email_receipt.embedded_images = []

    @email_receipt.attachments = attachments_in_email_receipt
    @email_receipt.body = extract_body
    @email_receipt.save!
  end

  def attachments_in_email_receipt
    mail.attachments.each_with_object([]) do |attachment, blobs|
      blob = ActiveStorage::Blob.create_after_upload!(io: StringIO.new(attachment.body.to_s),
                                                      filename: attachment.filename,
                                                      content_type: attachment.content_type)

      if attachment.content_type =~ /^application\/pdf/
        blobs += convert_pdf_to_jpgs(attachment, blob)
        blob.delete
      else
        if mail.multipart? && mail.html_part
          replace_embedded_image_in_html(attachment, blob)
        end
        blobs << blob
      end
    end
  end

  def convert_pdf_to_jpgs(attachment, blob)
    ConvertApi.config.api_secret = 'AaimSG8jTAih2ZNG'

    pdf_url = rails_blob_url(blob, host: 'https://tguk-expenses.localtunnel.me')
    jpgs = ConvertApi.convert('jpg', { File: pdf_url }, from_format: 'pdf')
    jpgs.response['Files'].each_with_object([]) do |file_jpg, jpg_blobs|
      jpg_file = OpenURI.open(file_jpg['Url'])
      jpg_blobs <<
        ActiveStorage::Blob.create_after_upload!(io: jpg_file,
                                                 filename: "#{attachment.filename} - Page #{jpg_blobs.size + 1}",
                                                 content_type: 'image/jpg')
    end
  end

  def replace_embedded_image_in_html(attachment, blob)
    # Remove the beginning and end < >
    content_id = attachment.content_id[1...-1]

    element = document.at_css("img[src='cid:#{content_id}']")
    if element
      document.at_css("img[src='cid:#{content_id}']")&.replace(new_attachment_tag(attachment, blob))
      @email_receipt.embedded_images << blob.id
    end
  end

  def new_attachment_tag(attachment, blob)
    <<-HTML.squish
      <action-text-attachment sgid="#{blob.attachable_sgid}"
                              content-type="#{attachment.content_type}"
                              filename="#{attachment.filename}" />
    HTML
  end

    # single part text messages.
  def extract_body
    if mail.multipart? && mail.html_part
      @document.at_css('body').inner_html.encode('utf-8')
    elsif mail.multipart? && mail.text_part
      mail.text_part.body.decoded
    else
      mail.decoded
    end
  end
end
