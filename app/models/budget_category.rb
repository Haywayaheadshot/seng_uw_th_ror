class BudgetCategory < ApplicationRecord
  acts_as_paranoid
  belongs_to :budget_cycle
  has_many :budget_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :budget_cycle_id }
  validates :spending_limit_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :total_spending_limit_within_cycle

  def utilization_rate(budget_cycle)
    return 0 unless budget_cycle&.total_budget&.positive?

    allocated = budget_projects.where(budget_cycle_id: budget_cycle.id).sum(:proposed_budget)
    (allocated / budget_cycle.total_budget * 100).round(2)
  end

  def allocated_amount(budget_cycle)
    budget_projects.where(budget_cycle_id: budget_cycle.id).sum(:proposed_budget)
  end

  private

  def total_spending_limit_within_cycle
    return unless budget_cycle

    total_limit = budget_cycle.budget_categories.sum(:spending_limit_percentage)
    total_limit += spending_limit_percentage if new_record? || spending_limit_percentage_changed?
    errors.add(:spending_limit_percentage, 'total across categories exceeds 100%') if total_limit > 100
  end
end
