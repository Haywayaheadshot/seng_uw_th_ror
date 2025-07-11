require 'rails_helper'

RSpec.describe BudgetProject, type: :model do
  let(:budget_cycle) { BudgetCycle.create!(name: '2025 Cycle', total_budget: 1_000_000, start_date: Date.today, end_date: Date.today + 1.year) }
  let(:budget_category) { BudgetCategory.create!(name: 'Infrastructure', spending_limit_percentage: 40, budget_cycle: budget_cycle) }
  let(:budget_project) do
    BudgetProject.new(
      name: 'Road Repair',
      proposed_budget: 100_000,
      budget_cycle: budget_cycle,
      budget_category: budget_category,
      impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 }
    )
  end

  describe 'associations' do
    it 'belongs to budget_cycle' do
      expect(BudgetProject.reflect_on_association(:budget_cycle).macro).to eq(:belongs_to)
    end

    it 'belongs to budget_category' do
      expect(BudgetProject.reflect_on_association(:budget_category).macro).to eq(:belongs_to)
    end

    it 'has many votes with dependent destroy' do
      association = BudgetProject.reflect_on_association(:votes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'requires name' do
      budget_project.name = nil
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:name]).to include("can't be blank")
    end

    it 'requires proposed_budget' do
      budget_project.proposed_budget = nil
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:proposed_budget]).to include("can't be blank")
    end

    it 'requires proposed_budget to be greater than 0' do
      budget_project.proposed_budget = 0
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:proposed_budget]).to include('must be greater than 0')

      budget_project.proposed_budget = -1
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:proposed_budget]).to include('must be greater than 0')
    end

    it 'requires impact_metrics' do
      budget_project.impact_metrics = nil
      expect(budget_project).not_to be_valid
      expect(budget_project.errors[:impact_metrics]).to include("can't be blank")
    end

    context 'valid_impact_metrics' do
      it 'requires estimated_beneficiaries to be an integer' do
        budget_project.impact_metrics = { estimated_beneficiaries: '500', timeline: '6 months', sustainability_score: 8 }
        expect(budget_project).not_to be_valid
        expect(budget_project.errors[:impact_metrics]).to include('must include estimated_beneficiaries as an integer')
      end

      it 'requires timeline to be a string' do
        budget_project.impact_metrics = { estimated_beneficiaries: 500, timeline: 6, sustainability_score: 8 }
        expect(budget_project).not_to be_valid
        expect(budget_project.errors[:impact_metrics]).to include('must include timeline as a string')
      end

      it 'requires sustainability_score to be between 1 and 10' do
        budget_project.impact_metrics = { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 11 }
        expect(budget_project).not_to be_valid
        expect(budget_project.errors[:impact_metrics]).to include('sustainability_score must be between 1 and 10')

        budget_project.impact_metrics = { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 0 }
        expect(budget_project).not_to be_valid
        expect(budget_project.errors[:impact_metrics]).to include('sustainability_score must be between 1 and 10')
      end
    end

    context 'within_category_spending_limit' do
      let!(:existing_project) do
        BudgetProject.create!(
          name: 'Bridge',
          proposed_budget: 300_000,
          budget_cycle: budget_cycle,
          budget_category: budget_category,
          impact_metrics: { estimated_beneficiaries: 1000, timeline: '12 months', sustainability_score: 7 }
        )
      end

      it 'allows creation if within category spending limit' do
        budget_project.proposed_budget = 100_000
      end

      it 'allows update if within category spending limit' do
        existing_project.update(proposed_budget: 200_000)
        budget_project.proposed_budget = 200_000
        expect(budget_project).to be_valid
      end
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the budget project' do
      budget_project.save!
      expect { budget_project.destroy }.to change { BudgetProject.count }.by(-1)
      expect(BudgetProject.with_deleted.find(budget_project.id)).to eq(budget_project)
      expect(budget_project.deleted_at).to be_present
    end
  end

  describe 'scopes' do
    describe '.approved' do
      let!(:approved_project) do
        BudgetProject.create!(
          name: 'Approved Project',
          proposed_budget: 100_000,
          budget_cycle: budget_cycle,
          budget_category: budget_category,
          approved: true,
          impact_metrics: { estimated_beneficiaries: 500, timeline: '6 months', sustainability_score: 8 }
        )
      end
      let!(:unapproved_project) do
        BudgetProject.create!(
          name: 'Unapproved Project',
          proposed_budget: 200_000,
          budget_cycle: budget_cycle,
          budget_category: budget_category,
          approved: false,
          impact_metrics: { estimated_beneficiaries: 1000, timeline: '12 months', sustainability_score: 7 }
        )
      end

      it 'returns only approved projects' do
        expect(BudgetProject.approved).to eq([approved_project])
      end
    end
  end

  describe '#estimated_beneficiaries' do
    it 'returns estimated_beneficiaries from impact_metrics' do
      budget_project.save!
      expect(budget_project.estimated_beneficiaries).to eq(500)
    end

    it 'returns 0 if impact_metrics is nil or missing estimated_beneficiaries' do
      budget_project.impact_metrics = nil
      expect(budget_project.estimated_beneficiaries).to eq(0)
      budget_project.impact_metrics = {}
      expect(budget_project.estimated_beneficiaries).to eq(0)
    end
  end

  describe '#timeline' do
    it 'returns timeline from impact_metrics' do
      budget_project.save!
      expect(budget_project.timeline).to eq('6 months')
    end

    it 'returns nil if impact_metrics is nil or missing timeline' do
      budget_project.impact_metrics = nil
      expect(budget_project.timeline).to be_nil
      budget_project.impact_metrics = {}
      expect(budget_project.timeline).to be_nil
    end
  end

  describe '#sustainability_score' do
    it 'returns sustainability_score from impact_metrics' do
      budget_project.save!
      expect(budget_project.sustainability_score).to eq(8)
    end

    it 'returns 0 if impact_metrics is nil or missing sustainability_score' do
      budget_project.impact_metrics = nil
      expect(budget_project.sustainability_score).to eq(0)
      budget_project.impact_metrics = {}
      expect(budget_project.sustainability_score).to eq(0)
    end
  end
end
