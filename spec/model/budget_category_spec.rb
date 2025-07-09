require 'rails_helper'

RSpec.describe BudgetCategory, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 40.0)
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      category = BudgetCategory.new(spending_limit_percentage: 40.0)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'is not valid with a negative spending_limit_percentage' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: -1.0)
      expect(category).not_to be_valid
      expect(category.errors[:spending_limit_percentage]).to include('must be greater than or equal to 0')
    end

    it 'is not valid with a spending_limit_percentage over 100' do
      category = BudgetCategory.new(name: 'Infrastructure', spending_limit_percentage: 101.0)
      expect(category).not_to be_valid
      expect(category.errors[:spending_limit_percentage]).to include('must be less than or equal to 100')
    end
  end
end
