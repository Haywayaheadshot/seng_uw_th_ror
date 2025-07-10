class VotingPhase < ApplicationRecord
  acts_as_paranoid

  enum :phase_status, { pre_selection: 0, final_voting: 1, implementation: 2 }, prefix: true

  belongs_to :budget_cycle

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than: :start_date }
  validates :voting_rules, presence: true
  validates :participant_eligibility, presence: true
  validate :dates_within_budget_cycle

  scope :active, -> { where('voting_phases.start_date <= ? AND voting_phases.end_date >= ?', Date.today, Date.today) }

  def active?
    Date.today.between?(start_date, end_date)
  end

  private

  def dates_within_budget_cycle
    return unless budget_cycle && start_date && end_date

    errors.add(:start_date, 'must be on or after budget cycle start date') if start_date < budget_cycle.start_date
    errors.add(:end_date, 'must be on or before budget cycle end date') if end_date > budget_cycle.end_date
  end
end
