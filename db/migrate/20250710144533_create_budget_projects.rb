class CreateBudgetProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_projects do |t|
      t.string :name, null: false
      t.decimal :proposed_budget, precision: 15, scale: 2, null: false
      t.references :budget_cycle, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :budget_projects, :deleted_at
  end
end
