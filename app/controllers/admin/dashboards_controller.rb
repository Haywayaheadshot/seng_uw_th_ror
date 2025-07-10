module Admin
  class DashboardsController < ApplicationController
    def index
      @budget_cycles = BudgetCycle.all.order('budget_cycles.start_date')
      @active_phases = VotingPhase.active.includes(:budget_cycle).order('budget_cycles.start_date')
      respond_to do |format|
        format.html
        format.json do
          render json: {
            budget_cycles: @budget_cycles.as_json(only: %i[id name start_date end_date total_budget]),
            active_phases: @active_phases.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility])
          }
        end
      end
    end
  end
end
