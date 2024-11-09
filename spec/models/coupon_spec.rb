require "rails_helper"

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:discount_type)}
    it { should validate_presence_of(:discount_value)}
    it { should validate_presence_of(:active)}
    it { should validate_presence_of(:merchant_id)}
    it { should validate_numericality_of(:discount_value).is_greater_than_or_equal_to(0)}
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end
end