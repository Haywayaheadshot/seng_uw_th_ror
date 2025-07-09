class Budget < ApplicationRecord
  belongs_to :budget_category
  belongs_to :budget_cycle
  validates :title, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validate :within_category_spending_limit

  private

  def within_category_spending_limit
    return unless budget_cycle && budget_category

    total_allocated = budget_category.allocated_amount(budget_cycle)
    total_allocated += total_amount.to_f - (persisted? ? Budget.find(id).total_amount : 0)

    allowed_limit = budget_cycle.total_budget * (budget_category.spending_limit_percentage / 100.0)

    return unless total_allocated > allowed_limit

    errors.add(:total_amount, "exceeds the category limit of #{budget_category.spending_limit_percentage}% (#{allowed_limit} of total budget)")
  end
end
