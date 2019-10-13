class ReceiptMailbox < ApplicationMailbox
  # mail => Mail object
  # inbound_email => ActionMailboxEmail record
  def process
    return if user.nil?
  end

  # locate the corresponding expense entry and tie the two together.
  def expense_entry
    @expense_entry ||= ExpenseEntry.find_by(email_receipt_token: email_receipt_token)
    if @expense_entry.expense_claim.user_id == user.id
      @expense_entry.receipt = inbound_email
    else
      @expense_entry = nil
    end
  end

  # Extract the email receipt token from the subject line
  def email_receipt_token
    @email_receipt_token ||= mail.subject[/receipt: ([[:alnum:]]{8})/, 1]
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end
end
