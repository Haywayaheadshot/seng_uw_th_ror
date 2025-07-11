require 'rails_helper'

RSpec.describe Admin::BudgetCyclesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }

  describe 'GET #index' do
    it 'assigns all budget cycles' do
      budget_cycle
      get :index
      expect(assigns(:budget_cycles)).to eq([budget_cycle])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested budget cycle' do
      get :show, params: { id: budget_cycle.id }
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new budget cycle' do
      get :new
      expect(assigns(:budget_cycle)).to be_a_new(BudgetCycle)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { name: '2026 Cycle', total_budget: 2_000_000, start_date: Date.today, end_date: Date.today + 1.year } }

      it 'creates a new budget cycle and redirects' do
        expect do
          post :create, params: { budget_cycle: valid_params }
        end.to change(BudgetCycle, :count).by(1)
        expect(response).to redirect_to(admin_budget_cycles_path)
        expect(flash[:notice]).to eq('Budget cycle created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', total_budget: -1000, start_date: Date.today + 1.year, end_date: Date.today } }

      it 'does not create a budget cycle and re-renders new' do
        expect do
          post :create, params: { budget_cycle: invalid_params }
        end.not_to change(BudgetCycle, :count)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested budget cycle' do
      get :edit, params: { id: budget_cycle.id }
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Updated 2025 Cycle', total_budget: 1_500_000 } }

      it 'updates the budget cycle and redirects' do
        patch :update, params: { id: budget_cycle.id, budget_cycle: valid_params }
        budget_cycle.reload
        expect(budget_cycle.name).to eq('Updated 2025 Cycle')
        expect(budget_cycle.total_budget).to eq(1_500_000)
        expect(response).to redirect_to(admin_budget_cycles_path)
        expect(flash[:notice]).to eq('Budget cycle updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', total_budget: -1000 } }

      it 'does not update the budget cycle and re-renders edit' do
        patch :update, params: { id: budget_cycle.id, budget_cycle: invalid_params }
        budget_cycle.reload
        expect(budget_cycle.name).not_to eq('')
        expect(budget_cycle.total_budget).not_to eq(-1000)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the budget cycle and redirects' do
      budget_cycle
      expect do
        delete :destroy, params: { id: budget_cycle.id }
      end.to change(BudgetCycle, :count).by(-1)
      expect(response).to redirect_to(admin_budget_cycles_path)
      expect(flash[:notice]).to eq('Budget cycle deleted successfully.')
    end
  end
end
