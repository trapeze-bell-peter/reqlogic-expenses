class Category
  CATEGORIES = { 'ACCOMMODATION' => { vat: 20, unit_cost: 0.30 },
                 'AIRFARE' => { vat: 0, unit_cost: 0.30 },
                 'CAR HIRE' => { vat: 20, unit_cost: 0.30 },
                 'CLIENT ENTERTAINMENT' => { vat: 20, unit_cost: 0.30 },
                 'FARES' => { vat: 0, unit_cost: 0.30 },
                 'MILEAGE' => { vat: 0, unit_cost: 0.45 },
                 'MILEAGE  PASSENGER' => { vat: 0, unit_cost: 0.50 },
                 'MILEAGE 10K' => { vat: 0, unit_cost: 0.25 },
                 'MILEAGE 10K PASSENGER' => { vat: 0, unit_cost: 0.30 },
                 'MISCELLANEOUS' => { vat: 20, unit_cost: nil },
                 'OFFICE SUPPLIES' => { vat: 20, unit_cost: nil },
                 'PARKING' => { vat: 20, unit_cost: nil },
                 'PETROL' => { vat: 20, unit_cost: nil },
                 'PHONE/INTERNET' => { vat: 20, unit_cost: nil },
                 'SUBSISTENCE' => { vat: 20, unit_cost: nil },
                 'TOLLS' => { vat: 0, unit_cost: nil } }.freeze

  def self.options_for_select(view)


  end
end