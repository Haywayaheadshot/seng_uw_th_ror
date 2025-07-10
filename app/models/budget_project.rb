class BudgetProject < ApplicationRecord
  acts_as_paranoid

  belongs_to :budget_cycle
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :proposed_budget, presence: true, numericality: { greater_than: 0 }
end
