class BudgetCycle < ApplicationRecord
  acts_as_paranoid

  has_many :budgets, dependent: :destroy
  has_many :voting_phases, dependent: :destroy
  validates :name, presence: true
  validates :total_budget, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
end
