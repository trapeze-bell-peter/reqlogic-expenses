class ExpenseClaim < ApplicationRecord
  has_many :expense_entries, dependent: :destroy

  attribute :claim_date, :date, default: -> { Time.zone.today }

  validates :claim_date, presence: true

  accepts_nested_attributes_for :expense_entries
end
