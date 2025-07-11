class CreateBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_categories do |t|
      t.string :name
      t.decimal :spending_limit_percentage
      t.bigint :budget_cycle_id, null: false
      t.datetime :deleted_at

      t.index :budget_cycle_id, name: 'index_budget_categories_on_budget_cycle_id'
      t.index :deleted_at, name: 'index_budget_categories_on_deleted_at'
      t.timestamps
    end

    add_foreign_key :budget_categories, :budget_cycles
  end
end
