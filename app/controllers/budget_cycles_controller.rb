class BudgetCyclesController < ApplicationController
  def index
    @budget_cycles = BudgetCycle.where('start_date <= ? AND end_date >= ?', Date.current, Date.current).where(deleted_at: nil)
  end
end
