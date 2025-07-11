require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:participant) { Participant.new(name: 'John Doe', age: 30) }

  describe 'associations' do
    it 'has many votes with dependent destroy' do
      association = Participant.reflect_on_association(:votes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'requires name' do
      participant.name = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:name]).to include("can't be blank")
    end

    it 'requires age' do
      participant.age = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:age]).to include("can't be blank")
    end

    it 'requires age to be greater than or equal to 0' do
      participant.age = -1
      expect(participant).not_to be_valid
      expect(participant.errors[:age]).to include('must be greater than or equal to 0')

      participant.age = 0
      expect(participant).to be_valid
    end
  end

  describe 'acts_as_paranoid' do
    it 'soft deletes the participant' do
      participant.save!
      expect { participant.destroy }.to change { Participant.count }.by(-1)
      expect(Participant.with_deleted.find(participant.id)).to eq(participant)
      expect(participant.deleted_at).to be_present
    end
  end
end
