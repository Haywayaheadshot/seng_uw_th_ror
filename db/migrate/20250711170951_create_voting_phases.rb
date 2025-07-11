class CreateVotingPhases < ActiveRecord::Migration[8.0]
  def change
    create_table :voting_phases do |t|
      t.string :name, null: false
      t.bigint :budget_cycle_id, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.jsonb :voting_rules, default: {}, null: false
      t.jsonb :participant_eligibility, default: {}, null: false
      t.integer :phase_status, default: 0, null: false
      t.datetime :deleted_at

      t.index :budget_cycle_id, name: 'index_voting_phases_on_budget_cycle_id'
      t.index :deleted_at, name: 'index_voting_phases_on_deleted_at'
      t.timestamps
    end

    add_foreign_key :voting_phases, :budget_cycles
  end
end
