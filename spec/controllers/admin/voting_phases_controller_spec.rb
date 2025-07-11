require 'rails_helper'

RSpec.describe Admin::VotingPhasesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:voting_phase) do
    VotingPhase.create!(name: 'Pre-selection', budget_cycle: budget_cycle, start_date: Date.today - 1.day, end_date: Date.today + 1.day, phase_status: 'pre_selection', voting_rules: { max_votes: 5 },
                        participant_eligibility: { min_age: 18 })
  end

  describe 'GET #new' do
    it 'assigns a new voting phase' do
      get :new, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:voting_phase)).to be_a_new(VotingPhase)
      expect(assigns(:voting_phase).budget_cycle).to eq(budget_cycle)
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          name: 'Final Voting',
          start_date: Date.today,
          end_date: Date.today + 2.days,
          phase_status: 'final_voting',
          voting_rules: { max_votes: 3 },
          participant_eligibility: { min_age: 21 }
        }
      end

      it 'creates a new voting phase and redirects' do
        expect do
          post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: valid_params }
        end.to change(VotingPhase, :count).by(1)
        expect(response).to redirect_to(admin_budget_cycle_voting_phases_path(budget_cycle))
        expect(flash[:notice]).to eq('Voting phase created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          name: '',
          start_date: Date.today + 2.days,
          end_date: Date.today,
          phase_status: '',
          voting_rules: { max_votes: -1 },
          participant_eligibility: { min_age: -5 }
        }
      end

      it 'does not create a voting phase and re-renders new' do
        expect do
          post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: invalid_params }
        end.not_to change(VotingPhase, :count)
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
