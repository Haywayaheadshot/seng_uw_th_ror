class CreateBudgetCycles < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_cycles do |t|
      t.string :name, null: false
      t.decimal :total_budget, precision: 10, scale: 2, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :deleted_at

      t.index :deleted_at, name: 'index_budget_cycles_on_deleted_at'
      t.timestamps
    end
  end
end
