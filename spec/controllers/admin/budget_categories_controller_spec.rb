require 'rails_helper'

RSpec.describe Admin::BudgetCategoriesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }

  describe 'GET #index' do
    let(:presenter) { instance_double(BudgetCategoriesPresenter, budget_categories: [budget_category]) }

    before do
      allow(BudgetCategoriesPresenter).to receive(:new).and_return(presenter)
    end

    it 'assigns presenter and budget categories' do
      get :index, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:presenter)).to eq(presenter)
      expect(assigns(:budget_categories)).to eq([budget_category])
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:index)
    end

    it 'handles search params' do
      allow(BudgetCategoriesPresenter).to receive(:new).with('infrastructure', budget_cycle.id.to_s).and_return(presenter)
      get :index, params: { search: 'infrastructure', budget_cycle_id: budget_cycle.id }
      expect(assigns(:budget_categories)).to eq([budget_category])
    end

    it 'handles missing budget_cycle_id' do
      get :index
      expect(assigns(:budget_cycle)).to be_nil
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new budget category and budget cycle' do
      get :new, params: { budget_cycle_id: budget_cycle.id }
      expect(assigns(:budget_category)).to be_a_new(BudgetCategory)
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:new)
    end

    it 'handles missing budget_cycle_id' do
      get :new
      expect(assigns(:budget_category)).to be_a_new(BudgetCategory)
      expect(assigns(:budget_cycle)).to be_nil
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Social Programs', spending_limit_percentage: 30, budget_cycle_id: budget_cycle.id } }

      it 'creates a new budget category and redirects' do
        expect do
          post :create, params: { budget_category: valid_params }
        end.to change(BudgetCategory, :count).by(1)
        expect(response).to redirect_to(admin_budget_categories_path(budget_cycle_id: budget_cycle.id))
        expect(flash[:notice]).to eq('Category created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', spending_limit_percentage: -10, budget_cycle_id: budget_cycle.id } }

      it 'does not create a budget category and re-renders new' do
        expect do
          post :create, params: { budget_category: invalid_params }
        end.not_to change(BudgetCategory, :count)
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the budget category and budget cycle' do
      get :edit, params: { id: budget_category.id }
      expect(assigns(:budget_category)).to eq(budget_category)
      expect(assigns(:budget_cycle)).to eq(budget_cycle)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Updated Infrastructure', spending_limit_percentage: 50 } }

      it 'updates the budget category and redirects' do
        patch :update, params: { id: budget_category.id, budget_category: valid_params }
        budget_category.reload
        expect(budget_category.name).to eq('Updated Infrastructure')
        expect(budget_category.spending_limit_percentage).to eq(50)
        expect(response).to redirect_to(admin_budget_categories_path(budget_cycle_id: budget_cycle.id))
        expect(flash[:notice]).to eq('Category updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', spending_limit_percentage: -10 } }

      it 'does not update the budget category and re-renders edit' do
        patch :update, params: { id: budget_category.id, budget_category: invalid_params }
        budget_category.reload
        expect(budget_category.name).not_to eq('')
        expect(budget_category.spending_limit_percentage).not_to eq(-10)
        expect(assigns(:budget_cycle)).to eq(budget_cycle)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the budget category and redirects' do
      budget_category
      expect do
        delete :destroy, params: { id: budget_category.id }
      end.to change(BudgetCategory, :count).by(-1)
      expect(response).to redirect_to(admin_budget_categories_path(budget_cycle_id: budget_cycle.id))
      expect(flash[:notice]).to eq('Category deleted successfully.')
    end
  end
end
