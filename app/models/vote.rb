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

    return unless created_at && (created_at < voting_phase.start_date || created_at > voting_phase.end_date)

    errors.add(:base, "Vote must be cast within the voting phase dates (#{voting_phase.start_date} to #{voting_phase.end_date})")
  end

  def participant_eligible
    return unless participant && voting_phase&.participant_eligibility

    min_age = voting_phase.participant_eligibility['min_age']
    return unless min_age && participant.age < min_age

    errors.add(:participant, "must be at least #{min_age} years old")
  end

  def within_max_votes
    return unless voting_phase&.voting_rules

    max_votes = voting_phase.voting_rules['max_votes']
    return unless max_votes

    current_votes = Vote.where(participant_id: participant_id, voting_phase_id: voting_phase_id).count
    return unless current_votes >= max_votes

    errors.add(:base, "Participant has reached the maximum of #{max_votes} votes for this phase")
  end
end
