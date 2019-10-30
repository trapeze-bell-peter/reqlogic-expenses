# frozen_string_literal: true

class ExpenseEntry < ApplicationRecord
  belongs_to :expense_claim

  has_one :barclay_card_row_datum, dependent: :destroy

  has_one_attached :receipt
  has_one :email_receipt

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

  before_update :delete_email_receipt, if: -> { self.receipt.attached? && self.receipt.changed? }

  # Virtual attribute to determine overall cost of an expense entry
  # @return [Money]
  def total_cost
    self.qty * self.unit_cost
  end

  # If we are uploading an image receipt, then remove
  def delete_email_receipt
    self.email_receipt.destroy!
  end
end
