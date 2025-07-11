class Participant < ApplicationRecord
  acts_as_paranoid

  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
