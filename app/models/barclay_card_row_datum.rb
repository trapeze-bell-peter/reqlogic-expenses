class BarclayCardRowDatum < ApplicationRecord
  belongs_to :expense_entry

  # Scopes to do the selective matching of the current CC record against other CC records.  Scopes support providing a
  # list of ids not to include so that the same CC records are not included in multiple categories.
  scope :match_on_description_mcc_amount,
        lambda { |record, excluded_ids|
          where(gbp_amount_pence: record.gbp_amount_pence).match_on_description_mcc(record, excluded_ids)
        }
  scope :match_on_description_mcc,
        ->(record, excluded_ids) { where(raw_description: record.raw_description).match_on_mcc(record, excluded_ids) }
  scope :match_on_mcc,
        ->(record, excluded_ids) { where(mcc: record.mcc).where.not(id: excluded_ids) }

  monetize :currency_amount_pence
  monetize :gbp_amount_pence

  delegate :description, to: :expense_entry

  # Returns a hash that ExpenseEntry can give to a create or update method to create a
  # corresponding ExpenseEntry.
  def attributes_for_expense_entry
    { date: self.transaction_date,
      description: cc_description,
      unit_cost: self.gbp_amount, qty: 1, vat: 0 }
  end

  # Generate a single string that combines the various fields from the CC import.
  def cc_description
    "#{self.raw_description} @ #{self.city} (#{self.mcc_description})" + forex?
  end

  # If the CC transaction involves foreign currency, provide a string that captures the forex amount.  Used by
  # {cc_description}.
  def forex?
    currency_amount.currency.iso_code != 'GBP' ? " (forex amount: #{self.currency_amount.format})" : ''
  end

  # Generates a hash with progressively less well matched previous transactions from BarclayCard imports for use by
  # {grouped_options_for_select}
  #
  # @return [Hash<Symbol, ActiveRecord::Relation]
  def prioritised_match_list
    @prioritised_match_list = { 'Original CC Description' => [self.cc_description] }
    @ids_so_far = [self.id]

    selective_match(:match_on_description_mcc_amount, 'Matches most fields')
    selective_match(:match_on_description_mcc, 'Matches Description and Merchant Category')
    selective_match(:match_on_mcc, 'Matches Merchant Category only')

    @prioritised_match_list
  end

  # Helper method that applies the scope, while not including any ids stored in @ids_so_far to avoid the same
  # item being listed multiple times.
  #
  # @api private
  # @param [Symbol] scope
  # @param [String] category
  def selective_match(scope, category)
    matching_records = BarclayCardRowDatum.includes(:expense_entry).send(scope, self, @ids_so_far)

    return if matching_records.empty?

    @ids_so_far += matching_records.ids
    @prioritised_match_list[category] = matching_records.map(&:description)
  end
end
