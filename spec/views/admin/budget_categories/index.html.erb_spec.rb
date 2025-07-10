# spec/views/admin/budget_categories/index.html.erb_spec.rb
require 'rails_helper'

RSpec.describe 'admin/budget_categories/index.html.erb', type: :view do
  include ActionView::Helpers::NumberHelper

  let(:budget_cycle1) { BudgetCycle.create!(name: '2024 Cycle', total_budget: 1_000_000, start_date: Date.today - 1.year, end_date: Date.today) }
  let(:budget_cycle2) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:category1) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40.0) }
  let(:category2) { BudgetCategory.create!(name: 'Social Programs', spending_limit_percentage: 30.0) }
  let(:presenter) { BudgetCategoriesPresenter.new(budget_cycle_id: budget_cycle2.id) }

  before do
    budget_cycle1
    budget_cycle2
    category1.budgets.create!(title: 'Road Repair', total_amount: 200_000, budget_cycle: budget_cycle2)
    assign(:budget_cycle, presenter.budget_cycle)
    assign(:budget_categories, presenter.categories)
    render
  end

  it 'displays utilization rate with progress bar' do
    expect(category1.utilization_rate(budget_cycle2)).to eq(20.0)
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="20.0"]')
    expect(rendered).to have_css('td div.bg-blue-500', text: '', minimum: 1)
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '20.0%')
    expect(rendered).not_to have_css('tr.bg-red-100')
  end

  it 'displays over-limit utilization correctly' do
    category1.budgets.destroy_all
    budget = category1.budgets.build(title: 'Road Repair', total_amount: 500_000, budget_cycle: budget_cycle2)
    budget.save!(validate: false)
    assign(:budget_categories, presenter.categories)
    render
    expect(category1.utilization_rate(budget_cycle2)).to eq(50.0)
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="50.0"]')
    expect(rendered).to have_css('td div.bg-red-500', text: '', minimum: 1)
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '50.0%')
    expect(rendered).to have_css('tr.bg-red-100', minimum: 1)
  end

  it 'displays within-limit utilization correctly' do
    expect(category1.utilization_rate(budget_cycle2)).to eq(20.0)
    expect(rendered).to have_css('td div[role="progressbar"][aria-valuenow="20.0"]')
    expect(rendered).to have_css('td div.bg-blue-500', text: '', minimum: 1)
    expect(rendered).to have_css('td span.text-sm.text-gray-600', text: '20.0%')
    expect(rendered).not_to have_css('tr.bg-red-100')
  end

  it 'shows allocated amount in tooltip' do
    expect(rendered).to have_css('td div[title="Allocated: $200,000.0"]')
  end

  it 'displays budget cycle dropdown' do
    expect(BudgetCycle.without_deleted.count).to eq(2)
    expect(rendered).to have_select('budget_cycle_id', with_options: ['Select Budget Cycle (default: latest)', '2024 Cycle', '2025 Cycle'])
  end

  it 'displays delete confirmation modal' do
    expect(rendered).to have_css('#confirm-modal.hidden[data-controller="confirm-modal"]')
    expect(rendered).to have_css('a[data-controller="confirm-modal"][data-action="click->confirm-modal#open"]')
    expect(rendered).to have_css('button[data-action="click->confirm-modal#confirm"]')
  end

  it 'displays a home button linking to dashboard' do
    expect(rendered).to have_link('Home', href: admin_dashboards_index_path)
  end

  # it 'renders the view exactly once' do
  #   expect { render }.to change { rendered.scan('Budget Categories').count }.from(0).to(1)
  # end

  # it 'does not display soft-deleted categories' do
  #   expect(rendered).to have_content('Infrastructure')
  #   expect(rendered).to have_content('Social Programs')
  #   category1.destroy
  #   assign(:budget_categories, presenter.categories)
  #   render
  #   expect(rendered).to have_content('Social Programs')
  #   expect(rendered).not_to have_content('Infrastructure')
  # end
end
