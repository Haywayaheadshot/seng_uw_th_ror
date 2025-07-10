class TransitionVotingPhaseJob < ApplicationJob
  queue_as :default

  def perform
    VotingPhase.where('end_date < ?', Date.today).each do |phase|
      next_phase = phase.budget_cycle.voting_phases
        .where('start_date > ?', phase.start_date)
        .order(:start_date)
        .first
      if next_phase
        phase.update(phase_status: :implementation)
        next_phase.update(phase_status: :final_voting) if Date.today.between?(next_phase.start_date, next_phase.end_date)
      else
        phase.update(phase_status: :implementation)
      end
    end
  end
end
