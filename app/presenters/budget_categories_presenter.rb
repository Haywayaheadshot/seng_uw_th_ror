class BudgetCategoriesPresenter
  def initialize(search: nil, budget_cycle_id: nil)
    @search = search
    @budget_cycle_id = budget_cycle_id
  end

  def categories
    scope = BudgetCategory.without_deleted
    scope = scope.where('name LIKE ?', "%#{@search}%") if @search.present?
    scope
  end

  def budget_cycle
    return unless @budget_cycle_id

    BudgetCycle.without_deleted.find_by(id: @budget_cycle_id)
  end

  def to_json(*_args)
    budget_cycle = self.budget_cycle || BudgetCycle.without_deleted.last || BudgetCycle.new(total_budget: 0, name: 'No Cycle')
    categories.map do |category|
      category.as_json.except('spending_limit_percentage', 'deleted_at').merge(
        'spending_limit_percentage' => category.spending_limit_percentage.to_f,
        'utilization_rate' => category.utilization_rate(budget_cycle).to_f
      )
    end
  end
end
