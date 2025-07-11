module Admin
  class BudgetProjectsController < BaseController
    before_action :set_budget_cycle
    before_action :set_budget_project, only: %i[show edit update destroy]

    def index
      @budget_projects = @budget_cycle.budget_projects
    end

    def show; end

    def new
      @budget_project = @budget_cycle.budget_projects.build
    end

    def create
      @budget_project = @budget_cycle.budget_projects.build(budget_project_params)
      if @budget_project.save
        redirect_to admin_budget_cycle_path(@budget_cycle), notice: 'Budget project created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @budget_project.update(budget_project_params)
        redirect_to admin_budget_cycle_path(@budget_cycle), notice: 'Budget project updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @budget_project.destroy
      redirect_to admin_budget_cycle_path(@budget_cycle), notice: 'Budget project deleted successfully.'
    end

    private

    def set_budget_cycle
      @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    end

    def set_budget_project
      @budget_project = @budget_cycle.budget_projects.find(params[:id])
    end

    def budget_project_params
      permitted = params.require(:budget_project).permit(:name, :approved, :proposed_budget, :budget_category_id, impact_metrics: %i[estimated_beneficiaries timeline sustainability_score])
      if permitted[:impact_metrics].present?
        permitted[:impact_metrics][:sustainability_score] = permitted[:impact_metrics][:sustainability_score].to_i if permitted[:impact_metrics][:sustainability_score].present?
        permitted[:impact_metrics][:estimated_beneficiaries] = permitted[:impact_metrics][:estimated_beneficiaries].to_i if permitted[:impact_metrics][:estimated_beneficiaries].present?
      end
      permitted
    end
  end
end
