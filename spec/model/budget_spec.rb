require 'rails_helper'

RSpec.describe Budget, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      budget = Budget.new(title: 'Road Repair', total_amount: 200_000, budget_category: category, budget_cycle: budget_cycle)
      expect(budget).to be_valid
    end

    it 'is not valid without a title' do
      budget = Budget.new(total_amount: 200_000, budget_category: category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:title]).to include("can't be blank")
    end

    it 'is not valid with a non-positive total_amount' do
      budget = Budget.new(title: 'Road Repair', total_amount: 0, budget_category: category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:total_amount]).to include('must be greater than 0')
    end

    it 'is not valid if total_amount exceeds category spending limit' do
      category.budgets.create!(title: 'Bridge Repair', total_amount: 300_000, budget_cycle: budget_cycle)
      budget = Budget.new(title: 'Road Repair', total_amount: 200_000, budget_category: category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:total_amount]).to include('exceeds the category limit of 40.0% (400000.0 of total budget)')
    end

    it 'is valid if total_amount is within category spending limit' do
      budget = Budget.new(title: 'Road Repair', total_amount: 200_000, budget_category: category, budget_cycle: budget_cycle)
      expect(budget).to be_valid
    end
  end
end
