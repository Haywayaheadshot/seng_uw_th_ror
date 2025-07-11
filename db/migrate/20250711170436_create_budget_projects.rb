class CreateBudgetProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_projects do |t|
      t.string :name, null: false
      t.decimal :proposed_budget, precision: 15, scale: 2, null: false
      t.bigint :budget_cycle_id, null: false
      t.bigint :budget_category_id, null: false
      t.datetime :deleted_at
      t.text :impact_metrics
      t.boolean :approved

      t.index :budget_cycle_id, name: 'index_budget_projects_on_budget_cycle_id'
      t.index :budget_category_id, name: 'index_budget_projects_on_budget_category_id'
      t.index :deleted_at, name: 'index_budget_projects_on_deleted_at'
      t.timestamps
    end

    add_foreign_key :budget_projects, :budget_cycles
    add_foreign_key :budget_projects, :budget_categories
  end
end
