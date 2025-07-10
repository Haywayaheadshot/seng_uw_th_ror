class AddBudgetCycleToBudgets < ActiveRecord::Migration[8.0]
  def change
    add_reference :budgets, :budget_cycle, null: false, foreign_key: true
  end
end
