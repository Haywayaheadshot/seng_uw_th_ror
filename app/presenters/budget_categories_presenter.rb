class BudgetCategoriesPresenter
  def initialize(search: nil, budget_cycle_id: nil)
    @search = search
    @budget_cycle_id = budget_cycle_id
  end

  def categories
    scope = BudgetCategory.all
    scope = scope.where('name ILIKE ?', "%#{@search}%") if @search.present?
    scope
  end

  def budget_cycle
    @budget_cycle_id ? BudgetCycle.find_by(id: @budget_cycle_id) : BudgetCycle.last
  end
end
