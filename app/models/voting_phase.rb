class VotingPhase < ApplicationRecord
  acts_as_paranoid
  belongs_to :budget_cycle
  has_many :votes, dependent: :destroy

  enum :phase_status, { pre_selection: 0, final_voting: 1, implementation: 2 }

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :voting_rules, presence: true
  validates :participant_eligibility, presence: true
  validate :end_date_after_start_date
  validate :within_budget_cycle_dates

  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }

  def active?
    Date.current.between?(start_date, end_date)
  end

  def transition_to_next_phase
    return unless active? && final_voting?

    update(phase_status: :implementation)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be greater than #{start_date}") if end_date <= start_date
  end

  def within_budget_cycle_dates
    return unless budget_cycle && start_date && end_date

    errors.add(:start_date, 'must be on or after budget cycle start date') if start_date < budget_cycle.start_date
    errors.add(:end_date, 'must be on or before budget cycle end date') if end_date > budget_cycle.end_date
  end
end
