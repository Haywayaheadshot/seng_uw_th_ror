require 'rails_helper'

RSpec.describe VotesController, type: :controller do
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
  let(:participant) { Participant.create!(name: 'John Doe', age: 25) }
  let(:valid_params) { { vote: { budget_project_id: budget_project.id, participant_id: participant.id } } }

  describe 'GET #new' do
    context 'with active voting phase' do
      before { voting_phase }

      it 'renders the new template' do
        get :new, params: { budget_cycle_id: budget_cycle.id }
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(assigns(:voting_phase)).to eq(voting_phase)
        expect(assigns(:budget_projects)).to include(budget_project)
        expect(assigns(:vote)).to be_a_new(Vote)
        expect(response).to render_template(:new)
      end
    end

    context 'without active voting phase' do
      it 'redirects to root with alert' do
        get :new, params: { budget_cycle_id: budget_cycle.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('No active voting phase available.')
      end
    end
  end

  describe 'GET #index' do
    it 'sets budget_cycle and renders index template' do
      get :index, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #create' do
    context 'with active voting phase' do
      before { voting_phase }

      context 'with valid params' do
        it 'creates a new vote and redirects for html' do
          expect do
            post :create, params: { budget_cycle_id: budget_cycle.id, **valid_params }
          end.to change(Vote, :count).by(1)
          expect(response).to redirect_to(budget_cycle_votes_path(budget_cycle))
          expect(flash[:notice]).to eq('Vote cast successfully.')
        end

        it 'creates a new vote for json' do
          post :create, params: { budget_cycle_id: budget_cycle.id, **valid_params }, format: :json
          expect(response.status).to eq(201)
          expect(response.parsed_body['voting_phase_id']).to eq(voting_phase.id)
        end

        it 'creates a new vote and updates form for turbo_stream' do
          post :create, params: { budget_cycle_id: budget_cycle.id, **valid_params }, format: :turbo_stream
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('vote_form')
          expect(assigns(:budget_projects)).to include(budget_project)
          expect(assigns(:vote)).to be_a_new(Vote)
        end
      end

      context 'with invalid params' do
        it 'renders new template with alert for html' do
          post :create, params: { budget_cycle_id: budget_cycle.id, vote: { budget_project_id: budget_project.id, participant_id: nil } }
          expect(response).to render_template(:new)
          expect(response.status).to eq(422)
        end

        it 'returns error for json' do
          post :create, params: { budget_cycle_id: budget_cycle.id, vote: { budget_project_id: budget_project.id, participant_id: nil } }, format: :json
          expect(response.status).to eq(422)
          expect(response.parsed_body['participant']).to include('must exist')
        end

        it 'renders form with errors for turbo_stream' do
          post :create, params: { budget_cycle_id: budget_cycle.id, vote: { budget_project_id: budget_project.id, participant_id: nil } }, format: :turbo_stream
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('vote_form')
        end
      end
    end

    context 'without active voting phase' do
      it 'redirects to root with alert for html' do
        post :create, params: { budget_cycle_id: budget_cycle.id, **valid_params }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('No active voting phase available.')
      end

      it 'returns error for json' do
        post :create, params: { budget_cycle_id: budget_cycle.id, **valid_params }, format: :json
        expect(response.status).to eq(422)
        expect(response.parsed_body['error']).to eq('No active voting phase available')
      end
    end
  end
end
