class AddDeletedAtToBudgetCycles < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_cycles, :deleted_at, :datetime
    add_index :budget_cycles, :deleted_at
  end
end
