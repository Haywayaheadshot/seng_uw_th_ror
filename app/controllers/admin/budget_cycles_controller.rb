module Admin
  class BudgetCyclesController < BaseController
    before_action :set_budget_cycle, only: %i[show edit update destroy]

    def index
      @budget_cycles = BudgetCycle.all.order(:start_date)
      respond_to do |format|
        format.html
        format.json { render json: @budget_cycles.as_json(only: %i[id name start_date end_date total_budget]) }
      end
    end

    def show
      respond_to do |format|
        format.html { redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle) }
        format.json { render json: @budget_cycle.as_json(only: %i[id name start_date end_date total_budget]) }
      end
    end

    def new
      @budget_cycle = BudgetCycle.new
      respond_to do |format|
        format.html
        format.json { render json: @budget_cycle }
      end
    end

    def create
      @budget_cycle = BudgetCycle.new(budget_cycle_params)
      respond_to do |format|
        if @budget_cycle.save
          format.html { redirect_to new_admin_budget_cycle_voting_phase_path(@budget_cycle), notice: 'Budget cycle created successfully. Now create a voting phase.' }
          format.json { render json: @budget_cycle, status: :created }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @budget_cycle.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html
        format.json { render json: @budget_cycle }
      end
    end

    def update
      respond_to do |format|
        if @budget_cycle.update(budget_cycle_params)
          format.html { redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle), notice: 'Budget cycle updated successfully.' }
          format.json { render json: @budget_cycle, status: :ok }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @budget_cycle.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @budget_cycle.destroy
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path, notice: 'Budget cycle deleted successfully.' }
        format.json { head :no_content }
      end
    end

    private

    def budget_cycle_params
      params.require(:budget_cycle).permit(:name, :total_budget, :start_date, :end_date)
    end
  end
end
