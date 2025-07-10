require 'rails_helper'

RSpec.describe BudgetCycle, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      cycle = BudgetCycle.new(name: '2025 Cycle', total_budget: 100_000, start_date: Date.today, end_date: Date.today + 1.year)
      expect(cycle).to be_valid
    end

    it 'is not valid without a name' do
      cycle = BudgetCycle.new(total_budget: 100_000, start_date: Date.today, end_date: Date.today + 1.year)
      expect(cycle).not_to be_valid
      expect(cycle.errors[:name]).to include("can't be blank")
    end

    it 'is not valid with a negative total_budget' do
      cycle = BudgetCycle.new(name: '2025 Cycle', total_budget: -100, start_date: Date.today, end_date: Date.today + 1.year)
      expect(cycle).not_to be_valid
      expect(cycle.errors[:total_budget]).to include('must be greater than 0')
    end

    it 'is not valid without start_date or end_date' do
      cycle = BudgetCycle.new(name: '2025 Cycle', total_budget: 100_000)
      expect(cycle).not_to be_valid
      expect(cycle.errors[:start_date]).to include("can't be blank")
      expect(cycle.errors[:end_date]).to include("can't be blank")
    end
  end
end
