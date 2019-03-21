# frozen_string_literal: true

class Category < ApplicationRecord
  monetize :unit_cost_pence
end