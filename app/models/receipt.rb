# frozen_string_literal: true

# Used to store details of a receipt associated with an expense_entry
class Receipt < ApplicationRecord
  belongs_to :expense_entry

  has_many_attached :attachments

  # User is defined by who this expense claim belongs to
  delegate :user, :user_id, to: :expense_entry
end
