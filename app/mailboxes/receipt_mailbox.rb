# frozen_string_literal: true

require 'convert_api'
require 'uri'

# Processing of incoming receipt emails.
class ReceiptMailbox < ApplicationMailbox
  include Rails.application.routes.url_helpers

  attr_reader :email_receipt

  # Check we are able to process this email as it matches an expense_entry and the user we are receiving from is
  # valid.
  before_processing do
    email_receipt_token =
      /^receipt(-(development|staging))?.([[:alnum:]]{8})@tguk-expenses\.com$/.match(mail.to.first)[3]
    @email_receipt = EmailReceipt.find_by(email_receipt_token: email_receipt_token)
    bounced! unless email_receipt && sender_is_claimant?
  end

  # Check that the sender of the email matches the claimant.
  def sender_is_claimant?
    mail.from.first == email_receipt.user.email
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
    email_receipt.mail = mail
    email_receipt.save!
    inform_user_of_email
  end

  private

  EMAIL_NOTIFICATION_CLASS = '"alert alert-success alert-block"'

  def inform_user_of_email
    NotificationsChannel.broadcast_to(
      email_receipt.user_id,
      expense_entry_id: email_receipt.expense_entry_id,
      msg_html: "<div class=#{EMAIL_NOTIFICATION_CLASS}>Email receipt for #{email_receipt.description} received</div>"
    )
  end
end
