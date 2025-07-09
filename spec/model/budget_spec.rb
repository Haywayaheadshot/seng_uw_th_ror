require 'rails_helper'

RSpec.describe Budget, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 100_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      budget = Budget.new(title: 'Road Repairs', total_amount: 30_000, budget_category: budget_category, budget_cycle: budget_cycle)
      expect(budget).to be_valid
    end

    it 'is not valid without a title' do
      budget = Budget.new(total_amount: 30_000, budget_category: budget_category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:title]).to include("can't be blank")
    end

    it 'is not valid with a negative total_amount' do
      budget = Budget.new(title: 'Road Repairs', total_amount: -100, budget_category: budget_category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:total_amount]).to include('must be greater than 0')
    end

    it 'is not valid without a budget_category' do
      budget = Budget.new(title: 'Road Repairs', total_amount: 30_000, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:budget_category]).to include('must exist')
    end

    it 'is not valid without a budget_cycle' do
      budget = Budget.new(title: 'Road Repairs', total_amount: 30_000, budget_category: budget_category)
      expect(budget).not_to be_valid
      expect(budget.errors[:budget_cycle]).to include('must exist')
    end

    it 'is not valid if total_amount exceeds category spending limit' do
      # Create an existing budget to consume part of the limit
      Budget.create!(title: 'Road Repairs', total_amount: 30_000, budget_category: budget_category, budget_cycle: budget_cycle)
      budget = Budget.new(title: 'Bridge Construction', total_amount: 20_000, budget_category: budget_category, budget_cycle: budget_cycle)
      expect(budget).not_to be_valid
      expect(budget.errors[:total_amount]).to include('exceeds the category limit of 40.0% (40000.0 of total budget)')
    end
  end
end
