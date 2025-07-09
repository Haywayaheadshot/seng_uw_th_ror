require 'rails_helper'

RSpec.describe 'admin/budget_categories/index.html.erb', type: :view do
  include ActionView::Helpers::NumberHelper

  let(:budget_cycle1) { BudgetCycle.create!(name: '2024 Cycle', total_budget: 1_000_000, start_date: Date.today - 1.year, end_date: Date.today) }
  let(:budget_cycle2) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:category1) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }
  let(:category2) { BudgetCategory.create!(name: 'Social Programs', spending_limit_percentage: 30.0) }

  before do
    category1.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle2) # 20% utilization
    assign(:budget_cycle, budget_cycle2)
    assign(:budget_categories, [category1, category2])
    render
  end

  it 'displays utilization rate with progress bar' do
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="20.0"]')
    expect(rendered).to have_css('td div.bg-blue-500', text: '', minimum: 1) # Blue for within 40%
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '20.0%')
    expect(rendered).not_to have_css('tr.bg-red-100') # No over-limit
  end

  it 'displays over-limit utilization correctly' do
    category1.budgets.destroy_all
    category1.budgets.create(title: 'Road Repair', total_amount: 500_000, budget_cycle: budget_cycle2) # 50% utilization
    allow_any_instance_of(Budget).to receive(:valid?).and_return(true) # Bypass validation
    render
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="50.0"]')
    expect(rendered).to have_css('td div.bg-red-500', text: '', minimum: 1) # Red for over 40%
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '50.0%')
    expect(rendered).to have_css('tr.bg-red-100', minimum: 1) # Row highlighted
  end

  it 'displays within-limit utilization correctly' do
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="20.0"]')
    expect(rendered).to have_css('td div.bg-blue-500', text: '', minimum: 1) # Blue for within limit
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '20.0%')
    expect(rendered).not_to have_css('tr.bg-red-100')
  end

  it 'shows allocated amount in tooltip' do
    expect(rendered).to have_css('td div[title="Allocated: $200,000"]')
  end

  it 'displays budget cycle dropdown' do
    expect(rendered).to have_select('budget_cycle_id', with_options: ['Select Budget Cycle (default: latest)', '2024 Cycle', '2025 Cycle'])
  end
end
