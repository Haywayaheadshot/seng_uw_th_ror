class Admin::BudgetCategoriesController < ApplicationController
  def index
    presenter = BudgetCategoriesPresenter.new(search: params[:search], budget_cycle_id: params[:budget_cycle_id])
    @budget_categories = presenter.categories
    @budget_cycle = presenter.budget_cycle || BudgetCycle.last
    respond_to do |format|
      format.html
      format.json do
        render json: @budget_categories.map { |category|
          category.as_json.except('spending_limit_percentage').merge(
            'spending_limit_percentage' => category.spending_limit_percentage.to_f,
            'utilization_rate' => category.utilization_rate(@budget_cycle).to_f
          )
        }
      end
    end
  end

  # Other actions unchanged
  def new
    @budget_category = BudgetCategory.new
    respond_to do |format|
      format.html
      format.json { render json: { error: 'Use POST to create a category' }, status: :method_not_allowed }
    end
  end

  def create
    @budget_category = BudgetCategory.new(budget_category_params)
    respond_to do |format|
      if @budget_category.save
        format.html { redirect_to admin_budget_categories_path, notice: 'Category created successfully.' }
        format.json { render json: @budget_category, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @budget_category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @budget_category = BudgetCategory.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: { error: 'Use PATCH/PUT to update a category' }, status: :method_not_allowed }
    end
  end

  def update
    @budget_category = BudgetCategory.find(params[:id])
    respond_to do |format|
      if @budget_category.update(budget_category_params)
        format.html { redirect_to admin_budget_categories_path, notice: 'Category updated successfully.' }
        format.json { render json: @budget_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @budget_category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @budget_category = BudgetCategory.find(params[:id])
    budget_count = @budget_category.budgets.count
    @budget_category.destroy
    respond_to do |format|
      notice = 'Category deleted successfully.'
      notice += " #{budget_count} associated budget(s) also deleted." if budget_count.positive?
      format.html { redirect_to admin_budget_categories_path, notice: notice }
      format.json { render json: { message: notice } }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to admin_budget_categories_path, alert: 'Category not found.' }
      format.json { render json: { error: 'Category not found' }, status: :not_found }
    end
  end

  private

  def budget_category_params
    params.require(:budget_category).permit(:name, :spending_limit_percentage)
  end
end
