require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
  let(:budget_project) do
    BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: budget_category,
                          impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
  end
  let(:participant) { Participant.create!(name: 'John Doe', age: 30) }
  let(:voting_phase) do
    VotingPhase.create!(name: 'Pre-selection', budget_cycle: budget_cycle, start_date: Date.today, end_date: Date.today + 1.day, phase_status: :pre_selection,
                        voting_rules: { max_votes: 5 }, participant_eligibility: { min_age: 18 })
  end

  describe 'GET #new' do
    context 'with active voting phase' do
      before { allow(budget_cycle).to receive(:current_voting_phase).and_return(voting_phase) }

      it 'assigns new vote, budget cycle, projects, and participants' do
        get :new, params: { budget_cycle_id: budget_cycle.id }
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(assigns(:voting_phase)).to eq(voting_phase)
        expect(assigns(:vote)).to be_a_new(Vote)
        expect(assigns(:budget_projects)).to include(budget_project)
        expect(assigns(:participants)).to include(participant)
        expect(response).to render_template(:new)
      end
    end

    context 'without active voting phase' do
      before { allow(budget_cycle).to receive(:current_voting_phase).and_return(nil) }

      it 'redirects to root with alert' do
        get :new, params: { budget_cycle_id: budget_cycle.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('No active voting phase available.')
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { budget_project_id: budget_project.id, participant_id: participant.id } }
    let(:invalid_params) { { budget_project_id: nil, participant_id: nil } }

    before { allow(budget_cycle).to receive(:current_voting_phase).and_return(voting_phase) }

    context 'with active voting phase' do
      context 'within category spending limit' do
        before { allow_any_instance_of(VotesController).to receive(:within_category_limit?).and_return(true) }

        context 'with valid params' do
          it 'creates a vote and redirects for HTML' do
            expect do
              post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }
            end.to change(Vote, :count).by(1)
            expect(response).to redirect_to(budget_cycle_votes_path(budget_cycle))
            expect(flash[:notice]).to eq('Vote cast successfully.')
          end

          it 'creates a vote and returns JSON' do
            post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }, format: :json
            expect(response).to have_http_status(:created)
            expect(JSON.parse(response.body)).to include('id', 'voting_phase_id', 'budget_project_id', 'participant_id', 'created_at')
          end

          it 'creates a vote and updates vote_form for Turbo Stream' do
            post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }, format: :turbo_stream
            expect(response.body).to include('vote_form')
            expect(assigns(:vote)).to be_a_new(Vote)
          end
        end
      end

      context 'exceeding category spending limit' do
        before { allow_any_instance_of(VotesController).to receive(:within_category_limit?).and_return(false) }

        it 'does not create a vote and adds error for HTML' do
          expect do
            post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }
          end.not_to change(Vote, :count)
          expect(assigns(:vote).errors[:base]).to include("Cannot vote: category #{budget_project.budget_category.name} exceeds spending limit")
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error for JSON' do
          post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include('base')
        end

        it 'updates vote_form with error for Turbo Stream' do
          post :create, params: { budget_cycle_id: budget_cycle.id, vote: valid_params }, format: :turbo_stream
          expect(response.body).to include('vote_form')
          expect(assigns(:vote).errors[:base]).to include("Cannot vote: category #{budget_project.budget_category.name} exceeds spending limit")
        end
      end
    end
  end
end
