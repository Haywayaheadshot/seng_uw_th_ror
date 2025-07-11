require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today - 1.day, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
  let(:approved_project) do
    BudgetProject.create!(name: 'Road Repair', proposed_budget: 100_000, budget_cycle: budget_cycle, budget_category: budget_category, approved: true,
                          impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 })
  end
  let(:unapproved_project) { BudgetProject.create!(name: 'Bridge', proposed_budget: 200_000, budget_cycle: budget_cycle, budget_category: budget_category, approved: false) }

  describe 'GET #index' do
    let(:query) { instance_double(DashboardQuery, active_budget_cycles: [budget_cycle], voting_reports: { budget_cycle.id => { votes_cast: 10 } }) }

    before do
      allow(DashboardQuery).to receive(:new).and_return(query)
    end

    it 'assigns query, active budget cycles, and voting reports' do
      get :index
      expect(assigns(:query)).to eq(query)
      expect(assigns(:budget_cycles)).to eq([budget_cycle])
      expect(assigns(:voting_reports)).to eq({ budget_cycle.id => { votes_cast: 10 } })
      expect(response).to render_template(:index)
    end
  end
end
