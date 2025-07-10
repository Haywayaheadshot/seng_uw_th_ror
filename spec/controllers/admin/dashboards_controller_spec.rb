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
  let(:project1) { BudgetProject.create!(budget_cycle: budget_cycle, name: 'Project A', proposed_budget: 100_000) }
  let(:project2) { BudgetProject.create!(budget_cycle: budget_cycle, name: 'Project B', proposed_budget: 200_000) }
  let(:participant1) { Participant.create!(name: 'Abubakar', age: 25) }
  let(:participant2) { Participant.create!(name: 'Jessica', age: 35) }

  describe 'GET #index' do
    context 'with admin access' do
      before { session[:admin] = true }

      it 'assigns budget cycles and active phases for html' do
        budget_cycle
        active_phase
        inactive_phase
        get :index
        expect(assigns(:budget_cycles)).to eq([budget_cycle])
        expect(assigns(:active_phases)).to eq([active_phase])
        expect(response).to render_template(:index)
      end

      it 'assigns voting reports for active cycles' do
        active_phase
        Vote.create!(voting_phase: active_phase, budget_project: project1, participant: participant1)
        Vote.create!(voting_phase: active_phase, budget_project: project2, participant: participant2)
        get :index
        expect(assigns(:budget_cycles)).to include(budget_cycle)
        expect(assigns(:voting_reports)).to be_present
        report = assigns(:voting_reports).first
        expect(report[:budget_cycle]).to eq(budget_cycle)
        expect(report[:voting_phase]).to eq(active_phase)
        expect(report[:vote_counts]).to eq({ 'Project A' => 1, 'Project B' => 1 })
        expect(report[:age_distribution]).to eq({ '25-34' => 1, '35-44' => 1 })
        expect(response).to render_template(:index)
      end

      it 'handles cycles with no active phase' do
        budget_cycle
        get :index
        expect(assigns(:budget_cycles)).to include(budget_cycle)
        expect(assigns(:voting_reports)).to be_empty
        expect(assigns(:active_phases)).to eq([])
        expect(response).to render_template(:index)
      end

      it 'returns json response with active phases and cycles' do
        budget_cycle
        active_phase
        inactive_phase
        get :index, format: :json
        expect(response.parsed_body).to eq({
                                             'budget_cycles' => [budget_cycle.as_json(only: %i[id name start_date end_date total_budget])],
                                             'active_phases' => [active_phase.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility])]
                                           })
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without admin access' do
      it 'redirects to root with alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Access denied')
      end
    end
  end
end
