class DashboardQuery
  def initialize
    @current_date = Date.current
  end

  def active_budget_cycles
    BudgetCycle.where('start_date <= ? AND end_date >= ?', @current_date, @current_date)
      .where(deleted_at: nil)
      .includes(voting_phases: :votes, budget_projects: :votes)
  end

  def active_phases
    active_budget_cycles.flat_map(&:voting_phases)
      .select { |phase| @current_date.between?(phase.start_date, phase.end_date) }
  end

  def voting_reports
    active_budget_cycles.map do |cycle|
      phase = cycle.voting_phases.find { |p| @current_date.between?(p.start_date, p.end_date) }
      next unless phase

      {
        budget_cycle: cycle,
        voting_phase: phase,
        vote_counts: vote_counts_for_phase(phase),
        age_distribution: age_distribution_for_phase(phase),
        impact_metrics: impact_metrics_for_cycle(cycle)
      }
    end.compact
  end

  private

  def vote_counts_for_phase(phase)
    project_names = BudgetProject.where(id: Vote.where(voting_phase_id: phase.id, deleted_at: nil)
                                        .select(:budget_project_id))
      .pluck(:id, :name)
      .to_h
    Vote.where(voting_phase_id: phase.id, deleted_at: nil)
      .group(:budget_project_id)
      .count
      .transform_keys { |id| project_names[id] || 'Unknown Project' }
  end

  def age_distribution_for_phase(phase)
    Vote.where(voting_phase_id: phase.id, deleted_at: nil)
      .joins(:participant)
      .group("CASE
                 WHEN participants.age < 18 THEN 'Under 18'
                 WHEN participants.age BETWEEN 18 AND 24 THEN '18-24'
                 WHEN participants.age BETWEEN 25 AND 34 THEN '25-34'
                 WHEN participants.age BETWEEN 35 AND 44 THEN '35-44'
                 ELSE '45+' END")
      .count
  end

  def impact_metrics_for_cycle(cycle)
    cycle.budget_projects.approved.where(deleted_at: nil).map do |project|
      {
        name: project.name,
        proposed_budget: project.proposed_budget,
        estimated_beneficiaries: project.estimated_beneficiaries,
        timeline: project.timeline,
        sustainability_score: project.sustainability_score
      }
    end
  end
end
