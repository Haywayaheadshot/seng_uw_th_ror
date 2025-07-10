require 'rails_helper'

RSpec.describe Admin::BudgetCategoriesController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }

  describe 'GET #index' do
    let!(:category1) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }
    let!(:category2) { BudgetCategory.create!(name: 'Social Programs', spending_limit_percentage: 30.0) }
    let(:presenter) { BudgetCategoriesPresenter.new(budget_cycle_id: budget_cycle.id) }

    before do
      category1.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle)
    end

    it 'returns all categories as HTML' do
      get :index
      expect(assigns(:budget_categories)).to match_array([category1, category2])
      expect(response).to render_template(:index)
    end

    it 'returns all categories as JSON with utilization_rate' do
      get :index, format: :json, params: { budget_cycle_id: budget_cycle.id }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        [
          { 'id' => category1.id, 'name' => 'Infrastructure', 'spending_limit_percentage' => 40.0, 'utilization_rate' => 20.0, 'created_at' => category1.created_at.as_json,
            'updated_at' => category1.updated_at.as_json },
          { 'id' => category2.id, 'name' => 'Social Programs', 'spending_limit_percentage' => 30.0, 'utilization_rate' => 0.0, 'created_at' => category2.created_at.as_json,
            'updated_at' => category2.updated_at.as_json }
        ]
      )
    end

    it 'filters categories by search query as JSON' do
      get :index, format: :json, params: { search: 'Infra', budget_cycle_id: budget_cycle.id }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        [{ 'id' => category1.id, 'name' => 'Infrastructure', 'spending_limit_percentage' => 40.0, 'utilization_rate' => 20.0, 'created_at' => category1.created_at.as_json,
           'updated_at' => category1.updated_at.as_json }]
      )
    end

    it 'returns correct JSON format' do
      expect(presenter.to_json).to include(
        a_hash_including(
          'name' => 'Infrastructure',
          'spending_limit_percentage' => 40.0,
          'utilization_rate' => 20.0
        )
      )
    end
  end

  describe 'GET #new' do
    it 'renders new template for HTML' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'returns method not allowed for JSON' do
      get :new, format: :json
      expect(response.parsed_body).to eq({ 'error' => 'Use POST to create a category' })
      expect(response).to have_http_status(:method_not_allowed)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { budget_category: { name: 'Education', spending_limit_percentage: 20.0 } } }
    let(:invalid_params) { { budget_category: { name: '', spending_limit_percentage: 20.0 } } }

    it 'creates a category and redirects for HTML' do
      post :create, params: valid_params
      expect(response).to redirect_to(admin_budget_categories_path)
      expect(flash[:notice]).to eq('Category created successfully.')
    end

    it 'creates a category and returns JSON' do
      post :create, params: valid_params, format: :json
      expect(response.parsed_body['name']).to eq('Education')
      expect(response).to have_http_status(:created)
    end

    it 'returns errors for invalid params in JSON' do
      post :create, params: invalid_params, format: :json
      expect(response.parsed_body).to eq({ 'errors' => ['Name can\'t be blank'] })
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET #edit' do
    let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }

    it 'renders edit template for HTML' do
      get :edit, params: { id: category.id }
      expect(response).to render_template(:edit)
    end

    it 'returns method not allowed for JSON' do
      get :edit, params: { id: category.id }, format: :json
      expect(response.parsed_body).to eq({ 'error' => 'Use PATCH/PUT to update a category' })
      expect(response).to have_http_status(:method_not_allowed)
    end
  end

  describe 'PATCH #update' do
    let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }
    let(:valid_params) { { id: category.id, budget_category: { name: 'Updated Infrastructure', spending_limit_percentage: 50.0 } } }
    let(:invalid_params) { { id: category.id, budget_category: { name: '', spending_limit_percentage: 50.0 } } }

    it 'updates a category and redirects for HTML' do
      patch :update, params: valid_params
      expect(response).to redirect_to(admin_budget_categories_path)
      expect(flash[:notice]).to eq('Category updated successfully.')
    end

    it 'updates a category and returns JSON' do
      patch :update, params: valid_params, format: :json
      expect(response.parsed_body['name']).to eq('Updated Infrastructure')
      expect(response).to have_http_status(:ok)
    end

    it 'returns errors for invalid params in JSON' do
      patch :update, params: invalid_params, format: :json
      expect(response.parsed_body).to eq({ 'errors' => ['Name can\'t be blank'] })
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    let(:category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }
    let!(:budget) { category.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle) }

    it 'deletes a category and associated budgets and redirects for HTML' do
      expect { delete :destroy, params: { id: category.id } }.to change { Budget.count }.by(-1)
      expect(response).to redirect_to(admin_budget_categories_path)
      expect(flash[:notice]).to eq('Category deleted successfully. 1 associated budget(s) also deleted.')
    end

    it 'deletes a category and associated budgets and returns JSON' do
      expect { delete :destroy, params: { id: category.id }, format: :json }.to change { Budget.count }.by(-1)
      expect(response.parsed_body).to eq({ 'message' => 'Category deleted successfully. 1 associated budget(s) also deleted.' })
      expect(response).to have_http_status(:ok)
    end

    it 'returns not found for non-existent category in JSON' do
      delete :destroy, params: { id: 999 }, format: :json
      expect(response.parsed_body).to eq({ 'error' => 'Category not found' })
      expect(response).to have_http_status(:not_found)
    end
  end
end
