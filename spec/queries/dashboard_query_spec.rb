require 'rails_helper'

RSpec.describe DashboardQuery do
  let(:query) { DashboardQuery.new }

  describe '#active_budget_cycles' do
    it 'returns active budget cycles' do
      active_cycle = BudgetCycle.create!(name: 'Active Cycle', total_budget: 100_000, start_date: Date.current - 1.day, end_date: Date.current + 1.day)
      inactive_cycle = BudgetCycle.create!(name: 'Inactive Cycle', total_budget: 100_000, start_date: Date.current + 1.day, end_date: Date.current + 2.days)
      expect(query.active_budget_cycles).to include(active_cycle)
      expect(query.active_budget_cycles).not_to include(inactive_cycle)
    end
  end

  describe '#voting_reports' do
    it 'returns vote counts and age distribution for active phases' do
      cycle = BudgetCycle.create!(name: 'Cycle', total_budget: 100_000, start_date: Date.current - 1.day, end_date: Date.current + 1.day)
      phase = cycle.voting_phases.create!(name: 'Phase 1', start_date: Date.current, end_date: Date.current + 1.day,
                                          phase_status: :pre_selection, voting_rules: { max_votes: 5 }, participant_eligibility: { min_age: 18 })
      project = BudgetProject.create!(name: 'Project A', budget_cycle: cycle, proposed_budget: 100_000)
      participant = Participant.create!(age: 30, name: 'Abubakar')
      Vote.create!(voting_phase: phase, budget_project: project, participant: participant)

      reports = query.voting_reports
      expect(reports.first[:vote_counts]).to eq({ 'Project A' => 1 })
      expect(reports.first[:age_distribution]).to eq({ '25-34' => 1 })
    end
  end
end
