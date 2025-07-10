module Admin::VotingPhasesHelper
  def humanize_phase_status(phase)
    phase.phase_status.humanize
  end

  def format_voting_rules(phase)
    phase.voting_rules['max_votes'] ? "Max Votes: #{phase.voting_rules['max_votes']}" : 'N/A'
  end

  def format_participant_eligibility(phase)
    phase.participant_eligibility['min_age'] ? "Min Age: #{phase.participant_eligibility['min_age']}" : 'N/A'
  end

  def phase_status_options
    VotingPhase.phase_statuses.keys.map { |s| [s.humanize, s] }
  end
end
