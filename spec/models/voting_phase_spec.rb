require 'rails_helper'

RSpec.describe VotingPhase, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }

  describe 'validations' do
    it 'requires name, start_date, end_date, voting_rules, and participant_eligibility' do
      phase = VotingPhase.new
      expect(phase).not_to be_valid
      expect(phase.errors.attribute_names).to include(:name, :start_date, :end_date, :voting_rules, :participant_eligibility, :budget_cycle)
    end

    it 'requires end_date to be after start_date' do
      phase = VotingPhase.new(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: Date.today,
        end_date: Date.today - 1.day,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 }
      )
      expect(phase).not_to be_valid
      expect(phase.errors[:end_date]).to include("must be greater than #{phase.start_date}")
    end

    it 'requires start_date to be on or after budget cycle start_date' do
      phase = VotingPhase.new(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: budget_cycle.start_date - 1.day,
        end_date: budget_cycle.end_date,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 }
      )
      expect(phase).not_to be_valid
      expect(phase.errors[:start_date]).to include('must be on or after budget cycle start date')
    end

    it 'requires end_date to be on or before budget cycle end_date' do
      phase = VotingPhase.new(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: budget_cycle.start_date,
        end_date: budget_cycle.end_date + 1.day,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 }
      )
      expect(phase).not_to be_valid
      expect(phase.errors[:end_date]).to include('must be on or before budget cycle end date')
    end
  end

  describe 'scopes' do
    it 'returns active phases' do
      active_phase = VotingPhase.create!(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: Date.today - 1.day,
        end_date: Date.today + 1.day,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 },
        phase_status: :pre_selection
      )
      inactive_phase = VotingPhase.create!(
        budget_cycle: budget_cycle,
        name: 'Final Voting',
        start_date: Date.today + 1.day,
        end_date: Date.today + 2.days,
        voting_rules: { max_votes: 3 },
        participant_eligibility: { min_age: 18 },
        phase_status: :pre_selection
      )
      expect(VotingPhase.active).to eq([active_phase])
    end
  end

  describe '#active?' do
    it 'returns true for active phase' do
      phase = VotingPhase.create!(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: Date.today - 1.day,
        end_date: Date.today + 1.day,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 },
        phase_status: :pre_selection
      )
      expect(phase.active?).to be true
    end

    it 'returns false for inactive phase' do
      phase = VotingPhase.create!(
        budget_cycle: budget_cycle,
        name: 'Pre-selection',
        start_date: Date.today + 1.day,
        end_date: Date.today + 2.days,
        voting_rules: { max_votes: 5 },
        participant_eligibility: { min_age: 18 },
        phase_status: :pre_selection
      )
      expect(phase.active?).to be false
    end
  end

  describe 'enum phase_status' do
    it 'defines phase statuses' do
      phase = VotingPhase.new
      expect(VotingPhase.phase_statuses).to eq({ 'pre_selection' => 0, 'final_voting' => 1, 'implementation' => 2 })
      expect(phase).to respond_to(:phase_status_pre_selection?)
      expect(phase).to respond_to(:phase_status_final_voting?)
      expect(phase).to respond_to(:phase_status_implementation?)
    end
  end
end
