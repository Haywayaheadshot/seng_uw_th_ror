class AddDeletedAtToBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_categories, :deleted_at, :datetime
    add_index :budget_categories, :deleted_at
  end
end
