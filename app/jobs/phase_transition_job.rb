class PhaseTransitionJob < ApplicationJob
  queue_as :default

  def perform
    VotingPhase.where('start_date <= ? AND end_date >= ?', Date.today, Date.today).each do |phase|
      phase.update(phase_status: :final_voting) if phase.phase_status_pre_selection?
    end
    VotingPhase.where('end_date < ?', Date.today).each(&:transition_to_next_phase)
  rescue StandardError => e
    Rails.logger.error("PhaseTransitionJob failed: #{e.message}")
  end
end
