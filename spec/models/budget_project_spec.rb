require 'rails_helper'

RSpec.describe BudgetProject, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }

  describe 'validations' do
    let(:budget_project) { BudgetProject.new(budget_cycle: budget_cycle, name: 'Project A', proposed_budget: 100_000) }

    it 'is valid with valid attributes' do
      expect(budget_project).to be_valid
    end

    it 'is not valid without a name' do
      budget_project.name = nil
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a proposed budget' do
      budget_project.proposed_budget = nil
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:proposed_budget]).to include("can't be blank")
    end

    it 'is not valid with a non-positive proposed budget' do
      budget_project.proposed_budget = 0
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:proposed_budget]).to include('must be greater than 0')
    end
  end
end
