# frozen_string_literal: true

# Class that holds one line of an expense claim.  Attached to it are the receipt (an image) or the email receipt.
# Additionally, if the expense entry was created from a BarclayCard upload, then the image is also attached.
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

  after_initialize { self.sequence ||= self.expense_claim.expense_entries.count }
  before_update :delete_email_receipt, if: -> { self.email_receipt && self.receipt.attached? && self.receipt.changed? }

  # Virtual attribute to determine overall cost of an expense entry
  # @return [Money]
  def total_cost
    self.qty * self.unit_cost
  end

  def destroy_receipt
    self.receipt.purge
    self.email_receipt&.destroy!
  end

  # If we are uploading an image receipt, then remove
  def delete_email_receipt
    self.email_receipt.destroy!
  end

  # Used to receive an image from Google.
  def image_receipt_url=(url)
    document = Nokogiri::HTML(URI.open(url))
    google_image_url = document.css('meta[property="og:image"]').attribute('content').value
    google_image_url = /(https:\/\/.*\.googleusercontent.com\/.*)=w[0-9]+-h[0-9]+.+/.match(google_image_url)[1]
    receipt.attach(io: URI.open(google_image_url), filename: "Receipt for #{self.sequence}", content_type: 'image/jpeg')
  end
end
