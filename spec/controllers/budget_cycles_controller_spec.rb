require 'rails_helper'

RSpec.describe BudgetCyclesController, type: :controller do
  describe 'GET #index' do
    let(:active_cycle) do
      BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 10.days, end_date: Date.today + 1.year)
    end
    let(:inactive_cycle) do
      BudgetCycle.create!(name: '2024 Cycle', total_budget: 500_000, start_date: Date.today - 2.years, end_date: Date.today - 1.year)
    end

    it 'assigns active budget cycles' do
      active_cycle
      inactive_cycle
      get :index
      expect(assigns(:budget_cycles)).to include(active_cycle)
      expect(assigns(:budget_cycles)).not_to include(inactive_cycle)
      expect(response).to render_template(:index)
    end

    it 'renders empty message when no active cycles' do
      get :index
      expect(assigns(:budget_cycles)).to be_empty
      expect(response).to render_template(:index)
    end
  end
end
