require 'rails_helper'

RSpec.describe BudgetCategory, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }

  describe 'associations' do
    it 'belongs to budget_cycle' do
      expect(BudgetCategory.reflect_on_association(:budget_cycle).macro).to eq(:belongs_to)
    end

    it 'has many budget_projects with dependent destroy' do
      association = BudgetCategory.reflect_on_association(:budget_projects)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'requires name' do
      budget_category.name = nil
      expect(budget_category).not_to be_valid
      expect(budget_category.errors[:name]).to include("can't be blank")
    end

    it 'requires unique name within budget cycle' do
      BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle)
      duplicate = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 30, budget_cycle: budget_cycle)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'requires spending_limit_percentage to be between 0 and 100' do
      budget_category.spending_limit_percentage = -1
      expect(budget_category).not_to be_valid
      expect(budget_category.errors[:spending_limit_percentage]).to include('must be greater than or equal to 0')

      budget_category.spending_limit_percentage = 101
      expect(budget_category).not_to be_valid
      expect(budget_category.errors[:spending_limit_percentage]).to include('must be less than or equal to 100')
    end

    context 'total_spending_limit_within_cycle' do
      let!(:existing_category) { BudgetCategory.create!(name: 'Social Programs', spending_limit_percentage: 60, budget_cycle: budget_cycle) }

      it 'allows creation if total spending limit is within 100%' do
        category = BudgetCategory.new(name: 'Education', spending_limit_percentage: 40, budget_cycle: budget_cycle)
        expect(category).to be_valid
      end

      it 'adds error if total spending limit exceeds 100% on creation' do
        category = BudgetCategory.new(name: 'Education', spending_limit_percentage: 41, budget_cycle: budget_cycle)
        expect(category).not_to be_valid
        expect(category.errors[:spending_limit_percentage]).to include('total across categories exceeds 100%')
      end

      it 'allows update if total spending limit remains within 100%' do
        existing_category.update(spending_limit_percentage: 30)
        new_category = BudgetCategory.new(name: 'Education', spending_limit_percentage: 70, budget_cycle: budget_cycle)
        expect(new_category).to be_valid
      end
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the budget category' do
      budget_category.save!
      expect { budget_category.destroy }.to change { BudgetCategory.count }.by(-1)
      expect(BudgetCategory.with_deleted.find(budget_category.id)).to eq(budget_category)
      expect(budget_category.deleted_at).to be_present
    end
  end

  describe '#utilization_rate' do
    let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
    let!(:project) do
      BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: category,
                            impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
    end

    it 'calculates utilization rate based on allocated amount' do
      expect(category.utilization_rate(budget_cycle)).to eq(10.0) # 100,000 / 1,000,000 * 100 = 10%
    end

    it 'returns 0 if budget cycle total_budget is zero' do
      budget_cycle.update(total_budget: 0)
      expect(category.utilization_rate(budget_cycle)).to eq(0)
    end

    it 'returns 0 if no budget cycle provided' do
      expect(category.utilization_rate(nil)).to eq(0)
    end
  end

  describe '#allocated_amount' do
    let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
    let!(:project1) do
      BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: category,
                            impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
    end
    let!(:project2) do
      BudgetProject.create!(name: 'Bridge', proposed_budget: 200_000, budget_cycle: budget_cycle, budget_category: category,
                            impact_metrics: { estimated_beneficiaries: 1000, timeline: '12 months', sustainability_score: 7 })
    end

    it 'sums proposed_budget of projects in the budget cycle' do
      expect(category.allocated_amount(budget_cycle)).to eq(300_000)
    end

    it 'returns 0 if no projects in the budget cycle' do
      other_cycle = BudgetCycle.create!(name: '2026 Cycle', total_budget: 500_000, start_date: Date.today, end_date: Date.today + 1.year)
      expect(category.allocated_amount(other_cycle)).to eq(0)
    end
  end
end
