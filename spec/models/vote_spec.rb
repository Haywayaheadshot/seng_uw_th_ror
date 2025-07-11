require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
  let(:budget_project) do
    BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: budget_category,
                          impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
  end
  let(:participant) { Participant.create!(name: 'John Doe', age: 30) }
  let(:voting_phase) do
    VotingPhase.create!(name: 'Pre-selection', budget_cycle: budget_cycle, start_date: Date.today, end_date: Date.today + 1.day, phase_status: 'pre_selection', voting_rules: { max_votes: 5 },
                        participant_eligibility: { min_age: 18 })
  end
  let(:vote) { Vote.new(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current) }

  describe 'associations' do
    it 'belongs to voting_phase' do
      expect(Vote.reflect_on_association(:voting_phase).macro).to eq(:belongs_to)
    end

    it 'belongs to budget_project' do
      expect(Vote.reflect_on_association(:budget_project).macro).to eq(:belongs_to)
    end

    it 'belongs to participant' do
      expect(Vote.reflect_on_association(:participant).macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    describe 'within_voting_phase_dates' do
      it 'is valid if created_at is within voting phase dates' do
        vote.created_at = Time.current
        expect(vote).to be_valid
      end

      it 'adds error if created_at is before voting phase start_date' do
        vote.created_at = voting_phase.start_date - 1.day
        expect(vote).not_to be_valid
        expect(vote.errors[:created_at]).to include('must be within voting phase dates')
      end

      it 'adds error if created_at is after voting phase end_date' do
        vote.created_at = voting_phase.end_date + 1.day
        expect(vote).not_to be_valid
        expect(vote.errors[:created_at]).to include('must be within voting phase dates')
      end
    end

    describe 'participant_eligible' do
      it 'is valid if participant meets minimum age requirement' do
        participant.update(age: 18)
        expect(vote).to be_valid
      end

      it 'adds error if participant is below minimum age' do
        participant.update(age: 17)
        expect(vote).not_to be_valid
        expect(vote.errors[:participant_id]).to include('must be at least 18 years old')
      end

      it 'is valid if no minimum age is specified' do
        voting_phase.update(participant_eligibility: {})
        participant.update(age: 0)
        expect(vote).to be_valid
      end
    end

    describe 'within_max_votes' do
      it 'is valid if participant has not exceeded max votes' do
        expect(vote).to be_valid
      end

      it 'is valid if max_votes is zero (no limit)' do
        voting_phase.update(voting_rules: { max_votes: 0 })
        5.times { Vote.create!(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current) }
        expect(vote).to be_valid
      end

      it 'adds error if participant exceeds max votes' do
        voting_phase.update(voting_rules: { max_votes: 2 })
        2.times { Vote.create!(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current) }
        expect(vote).not_to be_valid
        expect(vote.errors[:base]).to include('exceeds maximum votes of 2 for this phase')
      end

      it 'accounts for existing votes when updating' do
        vote.save!
        voting_phase.update(voting_rules: { max_votes: 1 })
        new_vote = Vote.new(voting_phase: voting_phase, budget_project: budget_project, participant: participant, created_at: Time.current)
        expect(new_vote).not_to be_valid
        expect(new_vote.errors[:base]).to include('exceeds maximum votes of 1 for this phase')
      end
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the vote' do
      vote.save!
      expect { vote.destroy }.to change { Vote.count }.by(-1)
      expect(Vote.with_deleted.find(vote.id)).to eq(vote)
      expect(vote.deleted_at).to be_present
    end
  end
end
