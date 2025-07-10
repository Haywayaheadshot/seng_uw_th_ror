require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }
  let(:active_phase) do
    VotingPhase.create!(
      budget_cycle: budget_cycle,
      name: 'Final Voting',
      start_date: Date.today - 1.day,
      end_date: Date.today + 1.day,
      voting_rules: { max_votes: 3 },
      participant_eligibility: { min_age: 18 },
      phase_status: :final_voting
    )
  end
  let(:inactive_phase) do
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

  describe 'GET #index' do
    it 'assigns all budget cycles and active phases for html' do
      budget_cycle
      active_phase
      inactive_phase
      get :index
      expect(assigns(:budget_cycles)).to eq([budget_cycle])
      expect(assigns(:active_phases)).to eq([active_phase])
      expect(response).to render_template(:index)
    end

    it 'returns json response with active phases' do
      budget_cycle
      active_phase
      inactive_phase
      get :index, format: :json
      expect(response.parsed_body).to eq({
                                           'budget_cycles' => [budget_cycle.as_json(only: %i[id name start_date end_date total_budget])],
                                           'active_phases' => [active_phase.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility])]
                                         })
    end
  end
end
