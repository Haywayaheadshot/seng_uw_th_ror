require 'rails_helper'

RSpec.describe BudgetCycle, type: :model do
  let(:budget_cycle) { BudgetCycle.new(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }

  describe 'associations' do
    it 'belongs to budget_categories with dependent destroy' do
      association = BudgetCycle.reflect_on_association(:budget_categories)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many budget_projects with dependent destroy' do
      association = BudgetCycle.reflect_on_association(:budget_projects)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many voting_phases with dependent destroy' do
      association = BudgetCycle.reflect_on_association(:voting_phases)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many votes through voting_phases' do
      association = BudgetCycle.reflect_on_association(:votes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:voting_phases)
    end
  end

  describe 'validations' do
    it 'requires name' do
      budget_cycle.name = nil
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:name]).to include("can't be blank")
    end

    it 'requires total_budget' do
      budget_cycle.total_budget = nil
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:total_budget]).to include("can't be blank")
    end

    it 'requires total_budget to be greater than 0' do
      budget_cycle.total_budget = 0
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:total_budget]).to include('must be greater than 0')

      budget_cycle.total_budget = -1
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:total_budget]).to include('must be greater than 0')
    end

    it 'requires start_date' do
      budget_cycle.start_date = nil
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:start_date]).to include("can't be blank")
    end

    it 'requires end_date' do
      budget_cycle.end_date = nil
      expect(budget_cycle).not_to be_valid
      expect(budget_cycle.errors[:end_date]).to include("can't be blank")
    end

    context 'end_date_after_start_date' do
      it 'allows end_date after start_date' do
        budget_cycle.start_date = Date.today
        budget_cycle.end_date = Date.today + 1.day
        expect(budget_cycle).to be_valid
      end

      it 'adds error if end_date is before start_date' do
        budget_cycle.start_date = Date.today
        budget_cycle.end_date = Date.today - 1.day
        expect(budget_cycle).not_to be_valid
        expect(budget_cycle.errors[:end_date]).to include('must be after start date')
      end

      it 'adds error if end_date equals start_date' do
        budget_cycle.start_date = Date.today
        budget_cycle.end_date = Date.today
        expect(budget_cycle).not_to be_valid
        expect(budget_cycle.errors[:end_date]).to include('must be after start date')
      end
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the budget cycle' do
      budget_cycle.save!
      expect { budget_cycle.destroy }.to change { BudgetCycle.count }.by(-1)
      expect(BudgetCycle.with_deleted.find(budget_cycle.id)).to eq(budget_cycle)
      expect(budget_cycle.deleted_at).to be_present
    end
  end

  describe '#current_voting_phase' do
    let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
    let!(:active_phase) do
      VotingPhase.create!(name: 'Pre-selection', budget_cycle: budget_cycle, start_date: Date.today, end_date: Date.today + 1.day, phase_status: 'pre_selection', voting_rules: { max_votes: 5 },
                          participant_eligibility: { min_age: 18 })
    end
    let!(:inactive_phase) do
      VotingPhase.create!(name: 'Final Voting', budget_cycle: budget_cycle, start_date: Date.today + 2.days, end_date: Date.today + 3.days, phase_status: 'final_voting',
                          voting_rules: { max_votes: 3 }, participant_eligibility: { min_age: 21 })
    end

    it 'returns the first active voting phase ordered by start_date' do
      allow(VotingPhase).to receive(:active).and_return(VotingPhase.where(id: active_phase.id))
      expect(budget_cycle.current_voting_phase).to eq(active_phase)
    end

    it 'returns nil if no active voting phase exists' do
      allow(VotingPhase).to receive(:active).and_return(VotingPhase.none)
      expect(budget_cycle.current_voting_phase).to be_nil
    end
  end
end
