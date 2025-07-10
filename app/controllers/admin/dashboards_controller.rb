module Admin
  class DashboardsController < ApplicationController
    before_action :restrict_to_admins

    def index
      dashboard_query = ::DashboardQuery.new
      @budget_cycles = dashboard_query.active_budget_cycles
      @active_phases = dashboard_query.active_phases
      @voting_reports = dashboard_query.voting_reports

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

    private

    def restrict_to_admins
      redirect_to root_path, alert: 'Access denied' unless session[:admin]
    end
  end
end
