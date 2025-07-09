class BudgetCycle < ApplicationRecord
  has_many :budgets, dependent: :destroy
  validates :name, presence: true
  validates :total_budget, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
end