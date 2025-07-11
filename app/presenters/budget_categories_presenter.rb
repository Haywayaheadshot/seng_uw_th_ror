class BudgetCategoriesPresenter
  def initialize(search = nil, budget_cycle_id = nil)
    @search = search
    @budget_cycle_id = budget_cycle_id
  end

  def budget_categories
    query = BudgetCategory.all
    query = query.where(budget_cycle_id: @budget_cycle_id) if @budget_cycle_id.present?
    query = query.where('name ILIKE ?', "%#{@search}%") if @search.present?
    query
  end

  def as_json(_options = {})
    budget_categories.map do |category|
      {
        id: category.id,
        name: category.name,
        spending_limit_percentage: category.spending_limit_percentage,
        utilization_rate: category.utilization_rate(BudgetCycle.find_by(id: @budget_cycle_id)),
        budget_cycle_id: category.budget_cycle_id
      }
    end
  end
end
