require 'rails_helper'

RSpec.describe Admin::BudgetCyclesController, type: :controller do
  let(:valid_params) do
    {
      name: '2025 Cycle',
      total_budget: 1_000_000,
      start_date: Date.today - 10.days,
      end_date: Date.today + 1.year
    }
  end

  describe 'GET #index' do
    let(:budget_cycle) { BudgetCycle.create!(valid_params) }

    it 'renders html template' do
      budget_cycle
      get :index
      expect(assigns(:budget_cycles)).to eq([budget_cycle])
      expect(response).to render_template(:index)
    end

    it 'returns json response' do
      budget_cycle
      get :index, format: :json
      expect(response.parsed_body).to eq([budget_cycle.as_json(only: %i[id name start_date end_date total_budget])])
    end
  end

  describe 'GET #new' do
    it 'renders html template' do
      get :new
      expect(assigns(:budget_cycle)).to be_a_new(BudgetCycle)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new budget cycle and redirects to new voting phase' do
        expect do
          post :create, params: { budget_cycle: valid_params }
        end.to change(BudgetCycle, :count).by(1)
        expect(response).to redirect_to(new_admin_budget_cycle_voting_phase_path(BudgetCycle.last))
      end

      it 'creates a new budget cycle for json' do
        post :create, params: { budget_cycle: valid_params }, format: :json
        expect(response.status).to eq(201)
        expect(response.parsed_body['name']).to eq('2025 Cycle')
      end
    end

    context 'with invalid params' do
      it 'renders new template for html' do
        post :create, params: { budget_cycle: { name: '' } }
        expect(response).to render_template(:new)
      end

      it 'returns error for json' do
        post :create, params: { budget_cycle: { name: '' } }, format: :json
        expect(response.status).to eq(422)
        expect(response.parsed_body['name']).to include("can't be blank")
      end
    end
  end
end
