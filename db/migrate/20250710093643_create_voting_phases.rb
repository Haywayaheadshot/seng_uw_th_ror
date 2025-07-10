class CreateVotingPhases < ActiveRecord::Migration[8.0]
  def change
    create_table :voting_phases do |t|
      t.string :name, null: false
      t.references :budget_cycle, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.jsonb :voting_rules, null: false, default: {}
      t.jsonb :participant_eligibility, null: false, default: {}
      t.integer :phase_status, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :voting_phases, :deleted_at
  end
end
