module Admin
  class BudgetCyclesController < BaseController
    def index
      @budget_cycles = BudgetCycle.all
    end

    def show
      @budget_cycle = BudgetCycle.find(params[:id])
    end

    def new
      @budget_cycle = BudgetCycle.new
    end

    def create
      @budget_cycle = BudgetCycle.new(budget_cycle_params)
      if @budget_cycle.save
        redirect_to admin_budget_cycles_path, notice: 'Budget cycle created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @budget_cycle = BudgetCycle.find(params[:id])
    end

    def update
      @budget_cycle = BudgetCycle.find(params[:id])
      if @budget_cycle.update(budget_cycle_params)
        redirect_to admin_budget_cycles_path, notice: 'Budget cycle updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @budget_cycle = BudgetCycle.find(params[:id])
      @budget_cycle.destroy
      redirect_to admin_budget_cycles_path, notice: 'Budget cycle deleted successfully.'
    end

    private

    def budget_cycle_params
      params.require(:budget_cycle).permit(:name, :total_budget, :start_date, :end_date)
    end
  end
end
