# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_22_171734) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "vat"
    t.integer "unit_cost_pence", default: 0, null: false
    t.string "unit_cost_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_claims", force: :cascade do |t|
    t.string "description"
    t.date "claim_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_entries", force: :cascade do |t|
    t.bigint "expense_claim_id"
    t.date "date"
    t.integer "sequence"
    t.string "category"
    t.string "description"
    t.string "project"
    t.integer "vat", default: 20, null: false
    t.integer "qty", default: 1, null: false
    t.integer "unit_cost_pence", default: 0, null: false
    t.string "unit_cost_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_claim_id"], name: "index_expense_entries_on_expense_claim_id"
  end

end
