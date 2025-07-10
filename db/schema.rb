# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_10_093643) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "budget_categories", force: :cascade do |t|
    t.string "name"
    t.decimal "spending_limit_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_budget_categories_on_deleted_at"
  end

  create_table "budget_cycles", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "total_budget", precision: 10, scale: 2, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_budget_cycles_on_deleted_at"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "title", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.bigint "budget_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "budget_cycle_id", null: false
    t.datetime "deleted_at"
    t.index ["budget_category_id"], name: "index_budgets_on_budget_category_id"
    t.index ["budget_cycle_id"], name: "index_budgets_on_budget_cycle_id"
    t.index ["deleted_at"], name: "index_budgets_on_deleted_at"
  end

  create_table "dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "voting_phases", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "budget_cycle_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.jsonb "voting_rules", default: {}, null: false
    t.jsonb "participant_eligibility", default: {}, null: false
    t.integer "phase_status", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_cycle_id"], name: "index_voting_phases_on_budget_cycle_id"
    t.index ["deleted_at"], name: "index_voting_phases_on_deleted_at"
  end

  add_foreign_key "budgets", "budget_categories"
  add_foreign_key "budgets", "budget_cycles"
  add_foreign_key "voting_phases", "budget_cycles"
end
