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

ActiveRecord::Schema[8.0].define(version: 20_250_711_171_135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_catalog.plpgsql'

  create_table 'budget_categories', force: :cascade do |t|
    t.string 'name'
    t.decimal 'spending_limit_percentage'
    t.bigint 'budget_cycle_id', null: false
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['budget_cycle_id'], name: 'index_budget_categories_on_budget_cycle_id'
    t.index ['deleted_at'], name: 'index_budget_categories_on_deleted_at'
  end

  create_table 'budget_cycles', force: :cascade do |t|
    t.string 'name', null: false
    t.decimal 'total_budget', precision: 10, scale: 2, null: false
    t.date 'start_date', null: false
    t.date 'end_date', null: false
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['deleted_at'], name: 'index_budget_cycles_on_deleted_at'
  end

  create_table 'budget_projects', force: :cascade do |t|
    t.string 'name', null: false
    t.decimal 'proposed_budget', precision: 15, scale: 2, null: false
    t.bigint 'budget_cycle_id', null: false
    t.bigint 'budget_category_id', null: false
    t.datetime 'deleted_at'
    t.text 'impact_metrics'
    t.boolean 'approved'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['budget_category_id'], name: 'index_budget_projects_on_budget_category_id'
    t.index ['budget_cycle_id'], name: 'index_budget_projects_on_budget_cycle_id'
    t.index ['deleted_at'], name: 'index_budget_projects_on_deleted_at'
  end

  create_table 'dashboards', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'participants', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'age', null: false
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['deleted_at'], name: 'index_participants_on_deleted_at'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'username', null: false
    t.string 'password_digest', null: false
    t.boolean 'admin', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['username'], name: 'index_users_on_username', unique: true
  end

  create_table 'votes', force: :cascade do |t|
    t.bigint 'voting_phase_id', null: false
    t.bigint 'budget_project_id', null: false
    t.bigint 'participant_id', null: false
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['budget_project_id'], name: 'index_votes_on_budget_project_id'
    t.index ['deleted_at'], name: 'index_votes_on_deleted_at'
    t.index ['participant_id'], name: 'index_votes_on_participant_id'
    t.index ['voting_phase_id'], name: 'index_votes_on_voting_phase_id'
  end

  create_table 'voting_phases', force: :cascade do |t|
    t.string 'name', null: false
    t.bigint 'budget_cycle_id', null: false
    t.date 'start_date', null: false
    t.date 'end_date', null: false
    t.jsonb 'voting_rules', default: {}, null: false
    t.jsonb 'participant_eligibility', default: {}, null: false
    t.integer 'phase_status', default: 0, null: false
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['budget_cycle_id'], name: 'index_voting_phases_on_budget_cycle_id'
    t.index ['deleted_at'], name: 'index_voting_phases_on_deleted_at'
  end

  add_foreign_key 'budget_categories', 'budget_cycles'
  add_foreign_key 'budget_projects', 'budget_categories'
  add_foreign_key 'budget_projects', 'budget_cycles'
  add_foreign_key 'votes', 'budget_projects'
  add_foreign_key 'votes', 'participants'
  add_foreign_key 'votes', 'voting_phases'
  add_foreign_key 'voting_phases', 'budget_cycles'
end
