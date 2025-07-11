module Admin
  class DashboardsController < BaseController
    def index
      @query = DashboardQuery.new
      @budget_cycles = @query.active_budget_cycles
      @voting_reports = @query.voting_reports
    end

    def impact_report
      @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
      @approved_projects = @budget_cycle.budget_projects.approved
      render :impact_report
    end
  end
end
