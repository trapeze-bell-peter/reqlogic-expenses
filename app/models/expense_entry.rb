# frozen_string_literal: true

# Class that holds one line of an expense claim.  Attached to it are the receipt (an image) or the email receipt.
# Additionally, if the expense entry was created from a BarclayCard upload, then the image is also attached.
class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim

  has_one :barclay_card_row_datum, dependent: :destroy

  has_one :receipt

  monetize :unit_cost_pence

  attribute :vat, :integer, default: 20
  attribute :qty, :integer, default: 1
  attribute :project, :string, default: 'EXPENSE'

  validates :date, presence: true
  validates :vat, inclusion: [0, 20]
  validates :project, presence: true
  validates :description, presence: true

  # User is defined by who this expense claim belongs to
  delegate :user, :user_id, to: :expense_claim

  after_initialize :set_sequence

  # Virtual attribute to determine overall cost of an expense entry
  # @return [Money]
  def total_cost
    self.qty * self.unit_cost
  end

  def destroy_receipt
    self.receipt.purge
    self.destroy_email_receipt
  end

  # If we are uploading an image receipt, then remove
  def destroy_email_receipt
    self.email_receipt.destroy!
  end

  def set_sequence
    return if self.expense_claim_id.nil?

    self.sequence ||= ExpenseEntry.where(expense_claim_id: self.expense_claim_id).count
  end
end
