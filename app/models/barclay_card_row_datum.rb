class BarclayCardRowDatum < ApplicationRecord
  belongs_to :expense_entry

  monetize :currency_amount_pence
  monetize :gbp_amount_pence

  # Take the row data from the CSV file and push into the DB
  def self.attributes_from_xlsx(row)
    { posting_date: row[3], raw_description: row[4], mcc: row[8], mcc_description: row[9],
      currency_amount: Money.new(row[10], row[11]), gbp_amount: row[12] }
  end

  # Returns a hash that ExpenseEntry can give to a create or update method to create a
  # corresponding ExpenseEntry.
  def attributes_for_expense_entry
    { date: self.posting_date,
      description: "#{self.raw_description} @ #{self.city} (#{self.mcc_description})" + forex?,
      unit_cost: self.gbp_amount, qty: 1, vat: 0
    }
  end

  def forex?
    currency_amount.currency.iso_code != 'GBP' ? " forex amount: #{self.currency_amount.format}" : ''
  end

  # Generates a hash with progressively less well matched previous transactions from BarclayCard imports
  # @return [Hash<Symbol, ActiveRecord::Relation]
  def prioritised_match_list
    matches_most = match_on_description_mcc_amount([self.id])
    matches_description_mcc = match_on_description_mcc(close_matches.ids.push(self.id))
    matches_mcc_only = matches_mcc_only(matches_description_mcc.ids.push(self.id))

    { matches_most: matches_most,
      matches_description_mcc: matches_description_mcc,
      match_mcc_only: matches_mcc_only
    }
  end

  private

  # @param [Array<Integer>] excluded_ids
  def match_on_description_mcc_amount(excluded_ids)
    where(amount: self.amount).match_on_description_mcc(excluded_ids)
  end

  def match_on_description_mcc(excluded_ids)
    where(description: self.description).match_on_mcc(excluded_ids)
  end

  def match_on_mcc(excluded_ids)
    where(mcc: self.mcc)
  end

  def where_not_self
    where.not(id: self.id)
  end
end
