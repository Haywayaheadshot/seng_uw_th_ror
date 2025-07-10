class UpdateVotingPhaseStatusJob < ApplicationJob
  queue_as :default

  def perform
    VotingPhase.where(phase_status: :pre_selection).where('start_date <= ?', Time.current).each do |phase|
      phase.update(phase_status: :final_voting)
    end
    VotingPhase.where(phase_status: :final_voting).where('end_date < ?', Time.current).each do |phase|
      phase.transition_to_next_phase
    end
  end
end
