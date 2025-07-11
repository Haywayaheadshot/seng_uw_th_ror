module Admin
  class BudgetCategoriesController < BaseController
    def index
      @presenter = BudgetCategoriesPresenter.new(params[:search], params[:budget_cycle_id])
      @budget_categories = @presenter.budget_categories
      @budget_cycle = BudgetCycle.find_by(id: params[:budget_cycle_id])
    end

    def new
      @budget_category = BudgetCategory.new
      @budget_cycle = BudgetCycle.find(params[:budget_cycle_id]) if params[:budget_cycle_id].present?
    end

    def create
      @budget_category = BudgetCategory.new(budget_category_params)
      if @budget_category.save
        redirect_to admin_budget_categories_path(budget_cycle_id: @budget_category.budget_cycle_id), notice: 'Category created successfully.'
      else
        @budget_cycle = BudgetCycle.find(params[:budget_category][:budget_cycle_id]) if params[:budget_category][:budget_cycle_id].present?
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @budget_category = BudgetCategory.find(params[:id])
      @budget_cycle = @budget_category.budget_cycle
    end

    def update
      @budget_category = BudgetCategory.find(params[:id])
      if @budget_category.update(budget_category_params)
        redirect_to admin_budget_categories_path(budget_cycle_id: @budget_category.budget_cycle_id), notice: 'Category updated successfully.'
      else
        @budget_cycle = @budget_category.budget_cycle
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @budget_category = BudgetCategory.find(params[:id])
      budget_cycle_id = @budget_category.budget_cycle_id
      @budget_category.destroy
      redirect_to admin_budget_categories_path(budget_cycle_id: budget_cycle_id), notice: 'Category deleted successfully.'
    end

    private

    def budget_category_params
      params.require(:budget_category).permit(:name, :spending_limit_percentage, :budget_cycle_id)
    end
  end
end
