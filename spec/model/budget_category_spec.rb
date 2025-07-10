# spec/models/budget_category_spec.rb (unchanged from previous)
require 'rails_helper'

RSpec.describe BudgetCategory, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }

  describe 'validations' do
    let!(:existing_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }

    it 'is valid with valid attributes' do
      category = BudgetCategory.new(name: 'Social Programs', spending_limit_percentage: 30.0)
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      category = BudgetCategory.new(spending_limit_percentage: 40.0)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'is not valid with a negative spending_limit_percentage' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: -1.0)
      expect(category).not_to be_valid
      expect(category.errors[:spending_limit_percentage]).to include('must be greater than or equal to 0')
    end

    it 'is not valid with a spending_limit_percentage over 100' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 101.0)
      expect(category).not_to be_valid
      expect(category.errors[:spending_limit_percentage]).to include('must be less than or equal to 100')
    end

    it 'is not valid with a duplicate name' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 30.0)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include('already exists. Please choose a different name or edit the existing category.')
    end
  end

  describe '#utilization_rate' do
    it 'returns 0 for no budgets' do
      expect(category.utilization_rate(budget_cycle)).to eq(0)
    end

    it 'calculates utilization rate based on budget allocations' do
      category.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle)
      category.budgets.create!(title: 'Bridge Repair', total_amount: 100_000, budget_cycle: budget_cycle)
      expect(category.utilization_rate(budget_cycle)).to eq(30.0)
    end
  end

  describe '#allocated_amount' do
    it 'returns 0 for no budgets' do
      expect(category.allocated_amount(budget_cycle)).to eq(0)
    end

    it 'sums total_amount for budgets in the cycle' do
      category.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle)
      category.budgets.create!(title: 'Bridge Repair', total_amount: 100_000, budget_cycle: budget_cycle)
      expect(category.allocated_amount(budget_cycle)).to eq(300_000)
    end
  end

  describe 'dependent: :destroy' do
    let!(:budget) { category.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle) }

    it 'destroys associated budgets when category is deleted' do
      expect { category.destroy }.to change { Budget.count }.by(-1)
    end
  end
end
