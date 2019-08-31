# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_31_050603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "barclay_card_row_data", force: :cascade do |t|
    t.date "transaction_date", null: false
    t.string "raw_description", null: false
    t.string "city"
    t.string "mcc", null: false
    t.string "mcc_description", null: false
    t.integer "currency_amount_pence", default: 0, null: false
    t.string "currency_amount_currency", default: "GBP", null: false
    t.integer "gbp_amount_pence", default: 0, null: false
    t.string "gbp_amount_currency", default: "GBP", null: false
    t.bigint "expense_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_entry_id"], name: "index_barclay_card_row_data_on_expense_entry_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "vat"
    t.integer "unit_cost_pence"
    t.string "unit_cost_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_claims", force: :cascade do |t|
    t.string "description"
    t.date "claim_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_expense_claims_on_user_id"
  end

  create_table "expense_entries", force: :cascade do |t|
    t.bigint "expense_claim_id"
    t.date "date"
    t.integer "sequence"
    t.string "category"
    t.string "description"
    t.string "project", null: false
    t.integer "vat", default: 20, null: false
    t.integer "qty", default: 1, null: false
    t.integer "unit_cost_pence", default: 0, null: false
    t.string "unit_cost_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_claim_id"], name: "index_expense_entries_on_expense_claim_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "barclay_card_row_data", "expense_entries"
  add_foreign_key "expense_claims", "users"
end
