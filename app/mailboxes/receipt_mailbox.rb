# frozen_string_literal: true

require 'convert_api'
require 'uri'

# Processing of incoming receipt emails.
class ReceiptMailbox < ApplicationMailbox
  include Rails.application.routes.url_helpers

  attr_reader :expense_entry

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
    EmailReceipt.find_or_create_by!(expense_entry_id: expense_entry.id) do |email_receipt|
      email_receipt.mail = mail
    end
    inform_user_of_email
  end

  private

  EMAIL_NOTIFICATION_CLASS = '"alert alert-success alert-block"'

  def inform_user_of_email
    NotificationsChannel.broadcast_to(
      @expense_entry.expense_claim.user_id,
      expense_entry_id: @expense_entry.id,
      msg_html: "<div class=#{EMAIL_NOTIFICATION_CLASS}>Email receipt for #{expense_entry.description} received</div>"
    )
  end
end
