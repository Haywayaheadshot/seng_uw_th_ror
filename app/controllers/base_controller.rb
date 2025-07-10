class BaseController < ApplicationController
  private

  def set_budget_cycle
    budget_cycle_id = params[:budget_cycle_id] || params[:id]
    @budget_cycle = BudgetCycle.find(budget_cycle_id)
  end
end
