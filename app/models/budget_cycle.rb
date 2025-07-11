class BudgetCycle < ApplicationRecord
  acts_as_paranoid

  has_many :budget_categories, dependent: :destroy
  has_many :budget_projects, dependent: :destroy
  has_many :voting_phases, dependent: :destroy
  has_many :votes, through: :voting_phases

  validates :name, presence: true
  validates :total_budget, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  def current_voting_phase
    voting_phases.active.order(:start_date).first
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date && end_date <= start_date

    errors.add(:end_date, 'must be after start date')
  end
end
