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

ActiveRecord::Schema.define(version: 2020_10_06_103401) do

  create_table "account_transactions", force: :cascade do |t|
    t.integer "account_id"
    t.string "bank_to_account"
    t.string "transaction_type"
    t.string "status"
    t.decimal "transefered_amount", precision: 10, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bank_to_code"
    t.string "bank_from_code"
    t.index ["account_id"], name: "index_account_transactions_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "customer_id"
    t.decimal "balance", precision: 10, scale: 5, default: "0.0"
    t.string "account_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_accounts_on_customer_id"
  end

  create_table "bank_conditions", force: :cascade do |t|
    t.integer "bank_id"
    t.string "external_bank_number"
    t.decimal "commission", precision: 10, scale: 5, default: "0.0"
    t.decimal "max_amount", precision: 10, scale: 5, default: "1000.0"
    t.decimal "min_amount", precision: 10, scale: 5, default: "1.0"
    t.string "transaction_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_bank_conditions_on_bank_id"
  end

  create_table "banks", force: :cascade do |t|
    t.string "name"
    t.string "bank_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "idn"
    t.integer "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_customers_on_bank_id"
  end

  create_table "ta_bank_registers", force: :cascade do |t|
    t.string "name"
    t.string "bank_number"
    t.string "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
