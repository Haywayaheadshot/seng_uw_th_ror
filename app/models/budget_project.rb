class BudgetProject < ApplicationRecord
  acts_as_paranoid
  belongs_to :budget_cycle
  belongs_to :budget_category
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :proposed_budget, presence: true, numericality: { greater_than: 0 }
  validates :impact_metrics, presence: true
  validate :valid_impact_metrics
  validate :within_category_spending_limit

  serialize :impact_metrics, coder: JSON
  scope :approved, -> { where(approved: true) }

  def estimated_beneficiaries
    impact_metrics&.dig('estimated_beneficiaries') || 0
  end

  def timeline
    impact_metrics&.dig('timeline')
  end

  def sustainability_score
    impact_metrics&.dig('sustainability_score') || 0
  end

  private

  def valid_impact_metrics
    return unless impact_metrics

    errors.add(:impact_metrics, 'must include estimated_beneficiaries as an integer') unless impact_metrics['estimated_beneficiaries'].is_a?(Integer)
    errors.add(:impact_metrics, 'must include timeline as a string') unless impact_metrics['timeline']&.is_a?(String)
    errors.add(:impact_metrics, 'must include sustainability_score as an integer') unless impact_metrics['sustainability_score'].is_a?(Integer)
    errors.add(:impact_metrics, 'sustainability_score must be between 1 and 10') unless impact_metrics['sustainability_score'].between?(1, 10)
  end

  def within_category_spending_limit
    return unless budget_cycle && budget_category

    total_allocated = budget_category.budget_projects.where(budget_cycle_id: budget_cycle.id).sum(:proposed_budget)
    total_allocated += proposed_budget.to_f - (persisted? ? BudgetProject.find(id).proposed_budget : 0)
    allowed_limit = budget_cycle.total_budget * (budget_category.spending_limit_percentage / 100.0)
    errors.add(:proposed_budget, "exceeds the category limit of #{budget_category.spending_limit_percentage}%") if total_allocated > allowed_limit
  end
end
