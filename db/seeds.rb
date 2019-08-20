# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.create!(name: 'ACCOMMODATION', vat: 20)
Category.create!(name: 'AIRFARE', vat: 0)
Category.create!(name: 'CAR HIRE', vat: 20)
Category.create!(name: 'CLIENT ENTERTAINMENT', vat: 20)
Category.create!(name: 'FARES', vat: 0)
Category.create!(name: 'MILEAGE', vat: 0, unit_cost: 0.45)
Category.create!(name: 'MILEAGE  PASSENGER', vat: 0, unit_cost: 0.50)
Category.create!(name: 'MILEAGE 10K', vat: 0, unit_cost: 0.25)
Category.create!(name: 'MILEAGE 10K PASSENGER', vat: 0, unit_cost: 0.30)
Category.create!(name: 'MISCELLANEOUS', vat: 20)
Category.create!(name: 'OFFICE SUPPLIES', vat: 20)
Category.create!(name: 'PARKING', vat: 20)
Category.create!(name: 'PETROL', vat: 20)
Category.create!(name: 'PHONE/INTERNET', vat: 20)
Category.create!(name: 'SUBSISTENCE', vat: 20)
Category.create!(name: 'TOLLS', vat: 0)

