class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.bigint :voting_phase_id, null: false
      t.bigint :budget_project_id, null: false
      t.bigint :participant_id, null: false
      t.datetime :deleted_at

      t.index :budget_project_id, name: 'index_votes_on_budget_project_id'
      t.index :participant_id, name: 'index_votes_on_participant_id'
      t.index :voting_phase_id, name: 'index_votes_on_voting_phase_id'
      t.index :deleted_at, name: 'index_votes_on_deleted_at'
      t.timestamps
    end

    add_foreign_key :votes, :voting_phases
    add_foreign_key :votes, :budget_projects
    add_foreign_key :votes, :participants
  end
end
