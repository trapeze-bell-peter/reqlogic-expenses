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

  # Process the inbound email.
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
