class Vote < ApplicationRecord
  acts_as_paranoid
  belongs_to :voting_phase
  belongs_to :budget_project
  belongs_to :participant

  validate :within_voting_phase_dates
  validate :participant_eligible
  validate :within_max_votes

  private

  def within_voting_phase_dates
    return unless voting_phase

    errors.add(:created_at, 'must be within voting phase dates') unless created_at&.between?(voting_phase.start_date, voting_phase.end_date)
  end

  def participant_eligible
    return unless voting_phase && participant

    min_age = voting_phase.participant_eligibility&.dig('min_age').to_i
    errors.add(:participant_id, "must be at least #{min_age} years old") if participant.age < min_age
  end

  def within_max_votes
    return unless voting_phase && participant

    max_votes = voting_phase.voting_rules&.dig('max_votes').to_i
    return if max_votes.zero?

    current_votes = participant.votes.where(voting_phase_id: voting_phase.id).count
    current_votes += 1 unless persisted?
    errors.add(:base, "exceeds maximum votes of #{max_votes} for this phase") if current_votes > max_votes
  end
end
