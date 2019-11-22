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

  after_initialize { self.sequence ||= self.expense_claim.expense_entries.count }

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

  EMAIL_NOTIFICATION_CLASS = '"alert alert-success alert-block"'

  # Used to receive an image from Google.
  def image_receipt_url=(url)
    document = Nokogiri::HTML(URI.open(url))
    google_image_url = document.css('meta[property="og:image"]').attribute('content').value
    google_image_url = /(https:\/\/.*\.googleusercontent.com\/.*)=w[0-9]+-h[0-9]+.+/.match(google_image_url)[1]
    receipt.attach(io: URI.open(google_image_url), filename: "Receipt for #{self.sequence}", content_type: 'image/jpeg')

    NotificationsChannel.broadcast_to(
      self.expense_claim.user_id,
      expense_entry_id: self.id,
      msg_html: "<div class=#{EMAIL_NOTIFICATION_CLASS}>Google image retrieved for #{self.description}</div>"
    )
  end
end
