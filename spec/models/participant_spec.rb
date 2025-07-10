require 'rails_helper'

RSpec.describe Participant, type: :model do
  describe 'validations' do
    let(:participant) { Participant.new(name: 'John Doe', age: 25) }

    it 'is valid with valid attributes' do
      expect(participant).to be_valid
    end

    it 'is not valid without a name' do
      participant.name = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without an age' do
      participant.age = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:age]).to include("can't be blank")
    end

    it 'is not valid with a negative age' do
      participant.age = -1
      expect(participant).not_to be_valid
      expect(participant.errors[:age]).to include('must be greater than or equal to 0')
    end
  end
end
