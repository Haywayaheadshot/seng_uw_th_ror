require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }
  let(:voting_phase) do
    VotingPhase.create!(
      budget_cycle: budget_cycle,
      name: 'Pre-selection',
      start_date: Date.today - 5.days,
      end_date: Date.today + 5.days,
      voting_rules: { max_votes: 3 },
      participant_eligibility: { min_age: 18 },
      phase_status: :pre_selection
    )
  end
  let(:budget_project) { BudgetProject.create!(budget_cycle: budget_cycle, name: 'Project A', proposed_budget: 100_000) }
  let(:participant) { Participant.create!(name: 'Abubakar', age: 25) }

  describe 'validations' do
    let(:vote) { Vote.new(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current) }

    it 'is valid with valid attributes' do
      expect(vote).to be_valid
    end

    it 'is not valid if outside voting phase dates' do
      vote.created_at = voting_phase.start_date - 1.day
      expect(vote).not_to be_valid
      expect(vote.errors[:base]).to include(/within the voting phase dates/)
    end

    it 'is not valid if participant is underage' do
      participant.update(age: 17)
      expect(vote).not_to be_valid
      expect(vote.errors[:participant]).to include('must be at least 18 years old')
    end

    it 'is not valid if participant exceeds max votes' do
      3.times { Vote.create!(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current) }
      expect(vote).not_to be_valid
      expect(vote.errors[:base]).to include('Participant has reached the maximum of 3 votes for this phase')
    end
  end
end
