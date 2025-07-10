require 'rails_helper'

RSpec.describe Admin::VotingPhasesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year) }
  let(:voting_phase) do
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
    before { voting_phase }

    it 'renders html template' do
      get :index, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:voting_phases)).to eq([voting_phase])
      expect(response).to render_template(:index)
    end

    it 'returns json response' do
      get :index, params: { budget_cycle_id: budget_cycle.id }, format: :json
      expect(response.parsed_body).to eq([voting_phase.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility])])
    end
  end

  describe 'GET #show' do
    before { voting_phase }

    it 'renders html template' do
      get :show, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id }
      expect(assigns(:voting_phase)).to eq(voting_phase)
      expect(response).to render_template(:show)
    end

    it 'returns json response' do
      get :show, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id }, format: :json
      expect(response.parsed_body).to eq(voting_phase.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility]))
    end
  end

  describe 'GET #new' do
    it 'renders html template' do
      get :new, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:voting_phase)).to be_a_new(VotingPhase)
      expect(response).to render_template(:new)
    end

    it 'returns json response' do
      get :new, params: { budget_cycle_id: budget_cycle.id }, format: :json
      expect(response.parsed_body).to include('budget_cycle_id' => budget_cycle.id)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        name: 'Final Voting',
        start_date: budget_cycle.start_date + 6.days,
        end_date: budget_cycle.start_date + 10.days,
        phase_status: 'pre_selection',
        voting_rules: { max_votes: 3 },
        participant_eligibility: { min_age: 18 }
      }
    end

    context 'with valid params' do
      it 'creates a new voting phase for html' do
        expect do
          post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: valid_params }
        end.to change(VotingPhase, :count).by(1)
        expect(response).to redirect_to(admin_budget_cycle_voting_phase_path(budget_cycle, VotingPhase.last))
      end

      it 'creates a new voting phase for json' do
        post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: valid_params }, format: :json
        expect(response.status).to eq(201)
        expect(response.parsed_body['name']).to eq('Final Voting')
      end
    end

    context 'with invalid params' do
      it 'renders new template for html' do
        post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: { name: '' } }
        expect(response).to render_template(:new)
      end

      it 'returns error for json' do
        post :create, params: { budget_cycle_id: budget_cycle.id, voting_phase: { name: '' } }, format: :json
        expect(response.status).to eq(422)
        expect(response.parsed_body['name']).to include("can't be blank")
      end
    end
  end

  describe 'PUT #update' do
    before { voting_phase }

    context 'with valid params' do
      it 'updates the voting phase for html' do
        put :update, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id, voting_phase: { name: 'Updated Phase' } }
        voting_phase.reload
        expect(voting_phase.name).to eq('Updated Phase')
        expect(response).to redirect_to(admin_budget_cycle_voting_phase_path(budget_cycle, voting_phase))
      end

      it 'updates the voting phase for json' do
        put :update, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id, voting_phase: { name: 'Updated Phase' } }, format: :json
        expect(response.status).to eq(200)
        expect(response.parsed_body['name']).to eq('Updated Phase')
      end
    end

    context 'with invalid params' do
      it 'renders edit template for html' do
        put :update, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id, voting_phase: { name: '' } }
        expect(response).to render_template(:edit)
      end

      it 'returns error for json' do
        put :update, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id, voting_phase: { name: '' } }, format: :json
        expect(response.status).to eq(422)
        expect(response.parsed_body['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    before { voting_phase }

    it 'destroys the voting phase for html' do
      expect do
        delete :destroy, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id }
      end.to change(VotingPhase, :count).by(-1)
      expect(response).to redirect_to(admin_budget_cycle_voting_phases_path(budget_cycle))
    end

    it 'destroys the voting phase for json' do
      delete :destroy, params: { budget_cycle_id: budget_cycle.id, id: voting_phase.id }, format: :json
      expect(response.status).to eq(204)
      expect(VotingPhase.count).to eq(0)
    end
  end
end
