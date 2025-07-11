require 'rails_helper'

RSpec.describe Admin::BudgetProjectsController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
  let(:budget_project) do
    BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: budget_category,
                          impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
  end

  describe 'GET #index' do
    it 'assigns budget projects for the budget cycle' do
      budget_project
      get :index, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:budget_projects)).to eq([budget_project])
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new budget project' do
      get :new, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:budget_project)).to be_a_new(BudgetProject)
      expect(assigns(:budget_project).budget_cycle).to eq(budget_cycle)
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          name: 'Bridge Construction',
          proposed_budget: 200_000,
          budget_category_id: budget_category.id,
          impact_metrics: { estimated_beneficiaries: 1000, timeline: '12 months', sustainability_score: 7 }
        }
      end

      it 'creates a new budget project and redirects' do
        expect do
          post :create, params: { budget_cycle_id: budget_cycle.id, budget_project: valid_params }
        end.to change(BudgetProject, :count).by(1)
        expect(response).to redirect_to(admin_budget_cycle_path(budget_cycle))
        expect(flash[:notice]).to eq('Budget project created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          name: '',
          proposed_budget: -100,
          budget_category_id: budget_category.id,
          impact_metrics: { estimated_beneficiaries: -10, timeline: '', sustainability_score: 15 }
        }
      end

      it 'does not create a budget project and re-renders new' do
        expect do
          post :create, params: { budget_cycle_id: budget_cycle.id, budget_project: invalid_params }
        end.not_to change(BudgetProject, :count)
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested budget project' do
      get :edit, params: { budget_cycle_id: budget_cycle.id, id: budget_project.id }
      expect(assigns(:budget_project)).to eq(budget_project)
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:valid_params) do
        {
          name: 'Updated Road Repair',
          proposed_budget: 150_000,
          impact_metrics: { estimated_beneficiaries: 600, timeline: '8 months', sustainability_score: 9 }
        }
      end

      it 'updates the budget project and redirects' do
        patch :update, params: { budget_cycle_id: budget_cycle.id, id: budget_project.id, budget_project: valid_params }
        budget_project.reload
        expect(budget_project.name).to eq('Updated Road Repair')
        expect(budget_project.proposed_budget).to eq(150_000)
        expect(budget_project.impact_metrics['estimated_beneficiaries']).to eq(600)
        expect(budget_project.impact_metrics['sustainability_score']).to eq(9)
        expect(response).to redirect_to(admin_budget_cycle_path(budget_cycle))
        expect(flash[:notice]).to eq('Budget project updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          name: '',
          proposed_budget: -100,
          impact_metrics: { estimated_beneficiaries: -10, sustainability_score: 15 }
        }
      end

      it 'does not update the budget project and re-renders edit' do
        patch :update, params: { budget_cycle_id: budget_cycle.id, id: budget_project.id, budget_project: invalid_params }
        budget_project.reload
        expect(budget_project.name).not_to eq('')
        expect(budget_project.proposed_budget).not_to eq(-100)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the budget project and redirects' do
      budget_project
      expect do
        delete :destroy, params: { budget_cycle_id: budget_cycle.id, id: budget_project.id }
      end.to change(BudgetProject, :count).by(-1)
      expect(response).to redirect_to(admin_budget_cycle_path(budget_cycle))
      expect(flash[:notice]).to eq('Budget project deleted successfully.')
    end
  end
end
