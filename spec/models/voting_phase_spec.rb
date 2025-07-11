require 'rails_helper'

RSpec.describe VotingPhase, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:voting_phase) do
    VotingPhase.new(
      name: 'Pre-selection',
      budget_cycle: budget_cycle,
      start_date: Date.today,
      end_date: Date.today + 1.day,
      phase_status: :pre_selection,
      voting_rules: { max_votes: 5 },
      participant_eligibility: { min_age: 18 }
    )
  end

  describe 'associations' do
    it 'belongs to budget_cycle' do
      expect(VotingPhase.reflect_on_association(:budget_cycle).macro).to eq(:belongs_to)
    end

    it 'has many votes with dependent destroy' do
      association = VotingPhase.reflect_on_association(:votes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'requires name' do
      voting_phase.name = nil
      expect(voting_phase).not_to be_valid
      expect(voting_phase.errors[:name]).to include("can't be blank")
    end

    it 'requires start_date' do
      voting_phase.start_date = nil
      expect(voting_phase).not_to be_valid
      expect(voting_phase.errors[:start_date]).to include("can't be blank")
    end

    it 'requires end_date' do
      voting_phase.end_date = nil
      expect(voting_phase).not_to be_valid
      expect(voting_phase.errors[:end_date]).to include("can't be blank")
    end

    it 'requires voting_rules' do
      voting_phase.voting_rules = nil
      expect(voting_phase).not_to be_valid
      expect(voting_phase.errors[:voting_rules]).to include("can't be blank")
    end

    it 'requires participant_eligibility' do
      voting_phase.participant_eligibility = nil
      expect(voting_phase).not_to be_valid
      expect(voting_phase.errors[:participant_eligibility]).to include("can't be blank")
    end

    context 'end_date_after_start_date' do
      it 'is valid if end_date is after start_date' do
        voting_phase.start_date = Date.today
        voting_phase.end_date = Date.today + 1.day
        expect(voting_phase).to be_valid
      end

      it 'adds error if end_date is before start_date' do
        voting_phase.start_date = Date.today
        voting_phase.end_date = Date.today - 1.day
        expect(voting_phase).not_to be_valid
        expect(voting_phase.errors[:end_date]).to include("must be greater than #{voting_phase.start_date}")
      end

      it 'adds error if end_date equals start_date' do
        voting_phase.start_date = Date.today
        voting_phase.end_date = Date.today
        expect(voting_phase).not_to be_valid
        expect(voting_phase.errors[:end_date]).to include("must be greater than #{voting_phase.start_date}")
      end
    end

    context 'within_budget_cycle_dates' do
      it 'is valid if dates are within budget cycle' do
        voting_phase.start_date = budget_cycle.start_date
        voting_phase.end_date = budget_cycle.end_date
        expect(voting_phase).to be_valid
      end

      it 'adds error if start_date is before budget cycle start_date' do
        voting_phase.start_date = budget_cycle.start_date - 1.day
        expect(voting_phase).not_to be_valid
        expect(voting_phase.errors[:start_date]).to include('must be on or after budget cycle start date')
      end

      it 'adds error if end_date is after budget cycle end_date' do
        voting_phase.end_date = budget_cycle.end_date + 1.day
        expect(voting_phase).not_to be_valid
        expect(voting_phase.errors[:end_date]).to include('must be on or before budget cycle end date')
      end
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the voting phase' do
      voting_phase.save!
      expect { voting_phase.destroy }.to change { VotingPhase.count }.by(-1)
      expect(VotingPhase.with_deleted.find(voting_phase.id)).to eq(voting_phase)
      expect(voting_phase.deleted_at).to be_present
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_phase) do
        VotingPhase.create!(
          name: 'Active Phase',
          budget_cycle: budget_cycle,
          start_date: Date.today - 1.day,
          end_date: Date.today + 1.day,
          phase_status: :pre_selection,
          voting_rules: { max_votes: 5 },
          participant_eligibility: { min_age: 18 }
        )
      end
      let!(:inactive_phase) do
        VotingPhase.create!(
          name: 'Inactive Phase',
          budget_cycle: budget_cycle,
          start_date: Date.today + 2.days,
          end_date: Date.today + 3.days,
          phase_status: :final_voting,
          voting_rules: { max_votes: 3 },
          participant_eligibility: { min_age: 21 }
        )
      end
    end
  end

  describe '#active?' do
    it 'returns true if current date is within phase dates' do
      voting_phase.start_date = Date.today
      voting_phase.end_date = Date.today + 1.day
      voting_phase.save!
      expect(voting_phase.active?).to be true
    end

    it 'returns false if current date is before start_date' do
      voting_phase.start_date = Date.today + 1.day
      voting_phase.end_date = Date.today + 2.days
      voting_phase.save!
      expect(voting_phase.active?).to be false
    end
  end

  describe '#transition_to_next_phase' do
    let(:voting_phase) do
      VotingPhase.create!(
        name: 'Final Voting',
        budget_cycle: budget_cycle,
        start_date: Date.today,
        end_date: Date.today + 1.day,
        phase_status: :final_voting,
        voting_rules: { max_votes: 3 },
        participant_eligibility: { min_age: 21 }
      )
    end

    it 'transitions to implementation if active and in final_voting phase' do
      expect(voting_phase.active?).to be true
      expect(voting_phase.final_voting?).to be true
      voting_phase.transition_to_next_phase
      expect(voting_phase.phase_status).to eq('implementation')
    end

    it 'does not transition if not active' do
      voting_phase.update(start_date: Date.today + 1.day, end_date: Date.today + 2.days)
      expect(voting_phase.active?).to be false
      voting_phase.transition_to_next_phase
      expect(voting_phase.phase_status).to eq('final_voting')
    end

    it 'does not transition if not in final_voting phase' do
      voting_phase.update(phase_status: :pre_selection)
      expect(voting_phase.final_voting?).to be false
      voting_phase.transition_to_next_phase
      expect(voting_phase.phase_status).to eq('pre_selection')
    end
  end
end
