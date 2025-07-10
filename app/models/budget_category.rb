class BudgetCategory < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true, uniqueness: { message: 'already exists. Please choose a different name or edit the existing category.' }
  validates :spending_limit_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  has_many :budgets, dependent: :destroy

  def utilization_rate(budget_cycle)
    return 0 unless budget_cycle&.total_budget&.positive?

    allocated = budgets.where(budget_cycle_id: budget_cycle.id).sum(:total_amount)
    (allocated / budget_cycle.total_budget * 100).round(2)
  end

  def allocated_amount(budget_cycle)
    budgets.where(budget_cycle_id: budget_cycle.id).sum(:total_amount)
  end
end
