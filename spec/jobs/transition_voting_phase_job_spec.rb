require 'rails_helper'
require 'timecop'

RSpec.describe TransitionVotingPhaseJob, type: :job do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }
  let(:phase1) do
    VotingPhase.create!(
      budget_cycle: budget_cycle,
      name: 'Pre-selection',
      start_date: budget_cycle.start_date,
      end_date: budget_cycle.start_date + 5.days,
      voting_rules: { max_votes: 5 },
      participant_eligibility: { min_age: 18 },
      phase_status: :pre_selection
    )
  end
  let(:phase2) do
    VotingPhase.create!(
      budget_cycle: budget_cycle,
      name: 'Final Voting',
      start_date: budget_cycle.start_date + 6.days,
      end_date: budget_cycle.start_date + 10.days,
      voting_rules: { max_votes: 3 },
      participant_eligibility: { min_age: 18 },
      phase_status: :pre_selection
    )
  end

  it 'transitions active phase to implementation and activates next phase' do
    phase1
    phase2
    expect(phase1).to be_phase_status_pre_selection
    expect(phase2).to be_phase_status_pre_selection
    Timecop.travel(budget_cycle.start_date + 6.days) do
      TransitionVotingPhaseJob.perform_now
      expect(phase1.reload).to be_phase_status_implementation
      expect(phase2.reload).to be_phase_status_final_voting
    end
  end
end
