require "rails_helper"

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:discount_type)}
    it { should validate_presence_of(:discount_value)}
    it { should validate_inclusion_of(:active).in_array([true, false]) }    
    it { should validate_numericality_of(:discount_value).is_greater_than_or_equal_to(0)}
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe "Merchant coupons endpoints" do
    before :each do
      @merchant1 = create(:merchant)
      @coupon1 = create(:coupon, merchant_id: @merchant1.id)
      @coupon2 = create(:coupon, merchant_id: @merchant1.id)
      @coupon3 = create(:coupon, merchant_id: @merchant1.id)
      @coupon4 = create(:coupon, merchant_id: @merchant1.id)
      @coupon5 = create(:coupon, merchant_id: @merchant1.id)
    end
    
    it "returns an error if you try to add more than five coupons to a merchant" do
      coupon6 = build(:coupon, merchant_id: @merchant1.id)

      expect(coupon6).not_to be_valid
    end
  end
end