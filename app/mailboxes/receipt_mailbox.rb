# frozen_string_literal: true

# Processing of incoming receipt emails.
class ReceiptMailbox < ApplicationMailbox
  # mail => Mail object
  # inbound_email => ActionMailboxEmail record
  def process
    email_receipt_token =
      /^receipt(-(development|staging))?.([[:alnum:]]{8})@tguk-expenses\.com$/.match(mail.to.first)[3]
    @expense_entry = ExpenseEntry.find_by(email_receipt_token: email_receipt_token)

    save_email_receipt if @expense_entry && sender_is_claimant?
  end

  # Check that the sender of the email matches the claimant.
  def sender_is_claimant?
    mail.from.first == @expense_entry.expense_claim.user.email
  end

  # Save the details in the incoming email in its own object
  def save_email_receipt
    @expense_entry.build_email_receipt unless @expense_entry.email_receipt
    @expense_entry.email_receipt.update!(title: mail.subject,
                                         body: body,
                                         attachments: attachments.map { |a| a[:blob] })
  end

  # Process the body of the incoming email.  Will deal with HTML messages, multipart text messages and
  # single part text messages.
  def body
    if mail.multipart? && mail.html_part
      extract_html_body
    elsif mail.multipart? && mail.text_part
      mail.text_part.body.decoded
    else
      mail.decoded
    end
  end

  # Process the incoming HTML body, storing any embedded attachments .
  def extract_html_body
    document = Nokogiri::HTML(mail.html_part.body.decoded)

    attachments.select { |a| a.content_id.present? }.each do |attachment_hash|
      attachment = attachment_hash[:original]
      blob = attachment_hash[:blob]

      # Remove the beginning and end < >
      content_id = attachment.content_id[1...-1]
      element = document.at_css "img[src='cid:#{content_id}']"

      element.replace "<action-text-attachment sgid=\"#{blob.attachable_sgid}\" content-type=\"#{attachment.content_type}\" filename=\"#{attachment.filename}\"></action-text-attachment>"
    end

    document.at_css('body').inner_html.encode('utf-8')
  end

  # Save all attachments.
  def attachments
    @attachments ||= mail.attachments.map do |attachment|
      blob = ActiveStorage::Blob.create_after_upload!(io: StringIO.new(attachment.body.to_s),
                                                      filename: attachment.filename,
                                                      content_type: attachment.content_type)
      { original: attachment, blob: blob }
    end
  end
end
