class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets do |t|
      t.string :title, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.references :budget_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
