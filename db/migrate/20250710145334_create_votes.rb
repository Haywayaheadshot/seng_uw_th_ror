class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :voting_phase, null: false, foreign_key: true
      t.references :budget_project, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :votes, :deleted_at
  end
end
